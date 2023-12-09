open Lwt.Infix
open Cohttp
open Cohttp_lwt_unix
open Soup

let main () =
  traverse input >>= fun docs ->
  let _ = Documents.mapi (fun key _document -> print_endline key) docs in
  Lwt.return ()

let () = Lwt_main.run (main ())
