open Piaf
open Soup

module UrlSet = Set.Make(String)
module DocumentMap = Map.Make(String)

let input = "https://henr.in/"

let fetch_doc env ~sw url =
  print_endline @@ Printf.sprintf "INFO: fetching doc: %s" url;

  match Client.Oneshot.get ~sw env (Uri.of_string url) with
  | Ok res ->
    if Status.is_successful res.status
    then Body.to_string res.body
    else 
      let msg = Status.to_string res.status in
      Result.Error (`Msg msg)
  | Error e -> failwith (Error.to_string e)

let doc_anchors html =
  let anchors = html $$ "a[href]" |> to_list in
  List.map (R.attribute "href") anchors

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

let sanitize_hrefs hrefs base_url =
  hrefs
  |> List.filter_map (fun href -> href_to_url href base_url)
;;

let has_visited_url url visited_urls = UrlSet.mem url visited_urls ;;

let traverse env switch url =
  let rec traverse urls_to_visit visited_urls documents =  
    match UrlSet.min_elt_opt urls_to_visit with
    | None -> documents
    | Some current_url ->
      let urls_to_visit = UrlSet.remove current_url urls_to_visit in 

      match has_visited_url url visited_urls with
      | true -> traverse urls_to_visit visited_urls documents
      | false ->
        let body = fetch_doc env ~sw:switch url in
        match body with
        | Ok res_body -> 
          let documents = DocumentMap.add url res_body documents in
    
          let hrefs = parse res_body |> doc_anchors in 
          let urls = 
            sanitize_hrefs hrefs input
            |> List.filter (from_same_domain input)
            |> List.filter (fun url -> not @@ has_visited_url url visited_urls)
            |> List.to_seq in

          let urls_to_visit = UrlSet.add_seq urls urls_to_visit in
          let visited_urls = UrlSet.add url visited_urls in
          traverse urls_to_visit visited_urls documents
        | Error e -> 
          print_endline @@ Printf.sprintf "ERROR: failed to fetch doc: %s" (Error.to_string e);
          traverse urls_to_visit visited_urls documents 
  in
  traverse (UrlSet.singleton url) UrlSet.empty DocumentMap.empty 

let traverse env url =
  Eio.Switch.run (fun switch ->
    traverse env switch url)
