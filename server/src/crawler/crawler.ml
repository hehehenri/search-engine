open Piaf

module UriSet = Set.Make(Uri)
module DocumentMap = Map.Make(Uri)

let _show_url_set url_set =
  print_endline @@ [%derive.show: Uri.t list] (UriSet.elements url_set) 

let _show_document_map document_map =
  print_endline @@ [%derive.show: (Uri.t * string) list] (DocumentMap.bindings document_map)

let _show_string_list string_list=
  print_endline @@ [%derive.show: string list] string_list

let fetch_doc ~env ~sw uri =
  Logs.info (fun m -> m "Fetching document: %s" (Uri.to_string uri));

  match Client.Oneshot.get ~sw env uri with
  | Ok res ->
    if Status.is_successful res.status
    then Body.to_string res.body
    else 
      let msg = Status.to_string res.status in
      Result.Error (`Msg msg)
  | Error e -> failwith (Error.to_string e)
;;

let from_same_domain uri uri' =
  let from_same_domain uri uri' =
    let (let*) = Option.bind in
    let* host = Uri.host uri in
    let* host' = Uri.host uri' in
    Some (host = host')
  in
  match from_same_domain uri uri' with
  | Some x -> x
  | None -> false
;;

let href_to_url href uri =
  match String.get href 0 with
  | '/' ->
    (* 
      This parses hrefs 
        from: /some/path 
        to:   http(s)://base-uri/some/path 
    *)
    let href_uri = Uri.of_string href in 
    let href_uri = Uri.with_path uri (Uri.path href_uri) in
    Some (href_uri)
  | _ -> 
    try
      (* Absolute_http.of_string will fail if the href is invalid *)
      let href_uri = Uri.Absolute_http.of_string href in
      Some (Uri.Absolute_http.to_uri href_uri)
    with
    _ -> None
  ;;

let has_visited_uri uri visited_uris =
  UriSet.mem uri visited_uris
;;

let sanitize_and_filter_hrefs ~uri hrefs visited_urls =
  hrefs
  |> List.filter_map (fun href -> href_to_url href uri)
  |> List.filter (from_same_domain uri)
  |> List.filter (fun url -> not @@ has_visited_uri url visited_urls)
;;

let traverse fetch_uri (uri:Uri.t) =
  let rec traverse urls_to_visit visited_urls documents =  
    match UriSet.min_elt_opt urls_to_visit with
    | None -> documents
    | Some current_uri ->
      let urls_to_visit = UriSet.remove current_uri urls_to_visit in 

      match has_visited_uri current_uri visited_urls with
      | true -> traverse urls_to_visit visited_urls documents
      | false ->
        let body = fetch_uri current_uri in
        match body with
        | Ok res_body ->
          let res_text = Parser.text res_body in
          let documents = DocumentMap.add current_uri res_text documents in
    
          let hrefs = Parser.anchors res_body in
          let urls = sanitize_and_filter_hrefs ~uri hrefs visited_urls in

          let urls_to_visit = 
            UriSet
        .add_seq (List.to_seq urls) urls_to_visit in
          let visited_urls = UriSet
        .add current_uri visited_urls in

          traverse urls_to_visit visited_urls documents
        | Error e -> 
          Logs.warn (fun m -> m "failed to fetch doc %s" (Error.to_string e));

          traverse urls_to_visit visited_urls documents 
  in
  traverse (UriSet.singleton uri) UriSet.empty DocumentMap.empty
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
        <h1>Simple Page</h1> 
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
    ("https://example.com/", "Simple HTML Boilerplate " ^ "Simple Page");
    ("https://example.com/first-link", "Simple HTML Boilerplate " ^ "Simple Page");
    ("https://example.com/second-link", "Simple HTML Boilerplate " ^ "Simple Page");
  ] in

  let documents = traverse fetch_url (Uri.of_string "https://example.com/") in
  [%test_eq: (string * string) list] expecting (DocumentMap.bindings documents |> List.map ~f:(fun (k, v) -> (Uri.to_string k, v)))
;;

let traverse ~env ~sw ~host =
  let fetch_doc = fetch_doc ~env ~sw in
  let uri = Uri.make ~scheme:"https" ~host () in
  traverse fetch_doc uri
