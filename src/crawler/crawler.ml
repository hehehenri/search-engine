open Lwt.Infix
open Cohttp
open Cohttp_lwt_unix
open Soup

module UrlSet = Set.Make(String)
module Documents = Map.Make(String)

let input = "https://henr.in/"

let fetch_doc url =
  let uri = Uri.of_string url in

  Client.get uri >>= fun (res, body) ->
  let status = res |> Response.status |> Code.code_of_status in
  Printf.printf "INFO: fetched %s: status(%d)\n" url status;

  Cohttp_lwt.Body.to_string body >>= fun body_str ->

  Lwt.return body_str

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

let traverse url =
  let rec traverse urls_to_visit visited_urls documents =
    let urls = urls_to_visit |> UrlSet.to_seq |>  List.of_seq in
  
    match urls with
    | [] -> Lwt.return documents
    | url :: _ ->
      match has_visited_url url visited_urls with
      | true ->
        let urls_to_visit = UrlSet.remove url urls_to_visit in 
        traverse urls_to_visit visited_urls documents
      | false ->
        fetch_doc url >>= fun res_body ->
        let documents = Documents.add url res_body documents in
      
        let hrefs = parse res_body |> doc_anchors in 
        let urls = 
          sanitize_hrefs hrefs input
          |> List.filter (from_same_domain input)
          |> List.filter (fun url -> not @@ has_visited_url url visited_urls)
          |> List.to_seq in

        let urls_to_visit = UrlSet.add_seq urls urls_to_visit in
        let visited_urls = UrlSet.add url visited_urls in
        traverse urls_to_visit visited_urls documents
  in

  traverse (UrlSet.singleton url) UrlSet.empty Documents.empty 

let main () =
  traverse input >>= fun docs ->
  let _ = Documents.mapi (fun key _document -> print_endline key) docs in
  Lwt.return ()
