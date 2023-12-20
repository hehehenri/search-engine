open Piaf

module UrlSet = Set.Make(String)
module DocumentMap = Map.Make(String)

let _show_url_set url_set =
  print_endline @@ [%derive.show: string list] (UrlSet.elements url_set) 

let _show_document_map document_map =
  print_endline @@ [%derive.show: (string * string) list] (DocumentMap.bindings document_map)

let _show_string_list string_list=
  print_endline @@ [%derive.show: string list] string_list

let fetch_doc ~env ~sw url =
  Logs.info (fun m -> m "Fetching document: %s" url);

  match Client.Oneshot.get ~sw env (Uri.of_string url) with
  | Ok res ->
    if Status.is_successful res.status
    then Body.to_string res.body
    else 
      let msg = Status.to_string res.status in
      Result.Error (`Msg msg)
  | Error e -> failwith (Error.to_string e)
;;

let url_domain url =
  let start_pos = String.index_opt url '/' |> Option.value ~default:(String.length url) in
  let end_pos = String.index_from_opt url start_pos '.' |> Option.value ~default:(String.length url) in
  String.sub url (start_pos + 2) (end_pos - start_pos - 2)
;;

let from_same_domain url url' =
  let domain = url_domain url in
  let domain' = url_domain url' in
  domain = domain'
;;

let merge_url base_url path =
  let normalized_base_url =
    if String.length base_url > 0 && base_url.[String.length base_url - 1] = '/' then
      base_url
    else
      base_url ^ "/"
  in
  let normalized_path =
    if String.length path > 0 && path.[0] = '/' then
      String.sub path 1 (String.length path - 1)
    else
      path
  in
  normalized_base_url ^ normalized_path
;;  

let href_to_url href base_url =
  match href |> String.to_seq |> List.of_seq with
  | 'h' :: 't' :: 't' :: 'p' :: _ -> Some href
  | '/' :: _ -> Some (merge_url base_url href)
  | _ -> None
;;

let has_visited_url url visited_urls = UrlSet.mem url visited_urls ;;

let sanitize_and_filter_hrefs ~base_url hrefs visited_urls =
  hrefs
  |> List.filter_map (fun href -> href_to_url href base_url)
  |> List.filter (from_same_domain base_url)
  |> List.filter (fun url -> not @@ has_visited_url url visited_urls)
;;

let traverse fetch_url base_url =
  let rec traverse urls_to_visit visited_urls documents =  
    match UrlSet.min_elt_opt urls_to_visit with
    | None -> documents
    | Some current_url ->
      let urls_to_visit = UrlSet.remove current_url urls_to_visit in 

      match has_visited_url current_url visited_urls with
      | true -> traverse urls_to_visit visited_urls documents
      | false ->
        let body = fetch_url current_url in
        match body with
        | Ok res_body ->
          let documents = DocumentMap.add current_url res_body documents in
    
          let hrefs = Parser.anchors res_body in 
          let urls = sanitize_and_filter_hrefs ~base_url hrefs  visited_urls in

          let urls_to_visit = 
            UrlSet.add_seq (List.to_seq urls) urls_to_visit in
          let visited_urls = UrlSet.add current_url visited_urls in

          traverse urls_to_visit visited_urls documents
        | Error e -> 
          Logs.warn (fun m -> m "failed to fetch doc %s" (Error.to_string e));

          traverse urls_to_visit visited_urls documents 
  in
  traverse (UrlSet.singleton base_url) UrlSet.empty DocumentMap.empty
;; 

open Base

let%test_unit "Crawler.traverse" =
  let anchor href =
    "<a href=\"" ^ href ^ "\" />" 
  in

  let html_with_anchors =
    let hrefs = ["/first-link"; "https://example.com/second-link"] in
    let anchors = List.fold_left hrefs ~init:"" ~f:(fun acc href -> acc ^ (anchor href)) in 
   
    {| <!DOCTYPE html>
      <html lang="en">
      <head>
        <title>Simple HTML Boilerplate</title>
      </head>
      <body> 
    |} ^ anchors ^ {|
      </body>
      </html>
    |}
  in

  let fetch_url _url =
    let resp = html_with_anchors in
    Ok resp
  in

  let expecting = [
    ("https://example.com/", html_with_anchors);
    ("https://example.com/first-link", html_with_anchors);
    ("https://example.com/second-link", html_with_anchors);
  ] in

  let documents = traverse fetch_url "https://example.com/" in
  [%test_eq: (string * string) list] expecting (DocumentMap.bindings documents)
;;

let traverse ~env ~sw url =
  let fetch_doc = fetch_doc ~env ~sw in
  traverse fetch_doc url
