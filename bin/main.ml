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
  Printf.printf "Response Status: %d\n" status;

  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  Printf.printf "Response Body:\n%s\n" body_str;

  Lwt.return body_str

let doc_anchors html =
  let anchors = html $$ "a[href]" |> to_list in
  List.map (R.attribute "href") anchors

let sanitize_urls urls visited_urls =
  urls
  (* Skip already visited urls *)
  |> List.filter(fun url -> not @@ UrlSet.mem url visited_urls)
  |> List.filter(fun url -> )

let traverse url =
  let rec traverse urls_to_visit visited_urls documents =
    let urls = urls_to_visit |> UrlSet.to_seq |>  List.of_seq in
  
    match urls with
    | [] -> Lwt.return documents
    | url :: _ ->
      let had_been_there = UrlSet.mem url visited_urls in
      match had_been_there with
      | true ->
        let urls_to_visit = UrlSet.remove url urls_to_visit in 
        traverse urls_to_visit visited_urls documents
      | false ->
        fetch_doc url >>= fun res_body ->
        let documents = Documents.add url res_body documents in
      
        let urls = parse res_body |> doc_anchors in 
        let not_visited_urls = List.filter(fun url -> not @@ UrlSet.mem url visited_urls) urls |> List.to_seq in

        let urls_to_visit = UrlSet.add_seq not_visited_urls urls_to_visit in
        let visited_urls = UrlSet.remove url visited_urls in
        traverse urls_to_visit visited_urls documents
  in

  traverse (UrlSet.singleton url) UrlSet.empty Documents.empty 

let main () =
  traverse input >>= fun docs ->
  let _ = Documents.mapi (fun key _document -> print_endline key) docs in
  Lwt.return ()

let () = Lwt_main.run (main ())
