open Piaf

type request = Piaf.Request_info.t Piaf.Server.ctx

let handle_health_check =
  let body = "Status: Health" in
  Response.of_string ~body `OK
;;

let handle_not_found = 
  Response.create `Not_found

let handle_index _uri =

  assert false

let request_handler (params : Request_info.t Server.ctx) =
  (* TODO: why do I feel I shouldn't be doing this?*)
  let path =
    Request.uri params.request
    |> Uri.path
    |> String.split_on_char '/' in

  match path with
  | [] | [""] -> handle_health_check
  | "index" :: url :: [] -> handle_index url
  | _ -> handle_not_found

let run ~sw ~host ~port env handler =
  let config =
    Server.Config.create (`Tcp (host, port))
  in
  let server = Server.create ~config handler in
  let command = Server.Command.start ~sw env server in
  command
;;

let serve ~sw env =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8080 env request_handler
;;
