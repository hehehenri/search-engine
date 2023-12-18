open Piaf

type request = Request_info.t Server.ctx

let handle_health_check () =
  Logs.info (fun m -> m "server.health_check");
  let body = "Status: Health" in
  Response.of_string ~body `OK

let handle_not_found () = 
  Logs.info (fun m -> m "server.not_found");
  Response.of_string ~body:"not found" `Not_found

let handle_index uri =
  Logs.info (fun m -> m "server.index(uri=%s)" uri);
  let body = Printf.sprintf "indexing %s..." uri in
  Response.of_string ~body `OK

let request_handler (params : Request_info.t Server.ctx) =
  let path =
     params.request
    |> Request.uri
    |> Uri.path
    |> String.split_on_char '/'
    |> List.filter (fun x -> String.length x > 0) in

  match path with
  | [] | [""] -> handle_health_check ()
  | "index" :: url :: [] -> handle_index url
  | _ -> handle_not_found ()

let host_to_str host = Fmt.str "%a" Eio.Net.Ipaddr.pp host

let run ~sw ~host ~port env =
  let config =
    Server.Config.create (`Tcp (host, port))
  in
  let server = Server.create ~config request_handler in
  print_endline @@ Printf.sprintf "listening on http://%s:%d/" (host_to_str host) port;
  let () = Eio.Net.Ipaddr.pp Format.str_formatter host in
  let command = Server.Command.start ~sw env server in
  command

let serve ~sw env =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8080 env
