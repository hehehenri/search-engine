open Piaf

let handle_health_check () =
  Logs.info (fun m -> m "server.handle_health_check");
  let body = "Status: Health" in
  Piaf.Response.of_string ~body `OK

let handle_not_found () = 
  Logs.info (fun m -> m "server.handle_not_found");
  Piaf.Response.of_string ~body:"not found" `Not_found

let cors_middleware handler req =
  let response : Piaf.Response.t = handler req in
  let add_header name value headers = Piaf.Headers.add headers name value in
  let headers =
    response.headers
    |> add_header "Access-Control-Allow-Origin" "*"
    |> add_header "Access-Control-Allow-Headers" "*"
    |> add_header "Allow" "*"
  in
  let response = 
    Piaf.Response.create ~version:response.version ~headers ~body:response.body
      response.status
  in
  response
;;

let request_handler ~env ~sw ~(deps:Deps.deps) (params : Request_info.t Server.ctx) =
  let meth = params.request.meth in
  let path = 
      params.request
    |> Request.uri
    |> Uri.path in

  Logs.info (fun m -> m "Handle request: %a" Request.pp_hum params.request);

  let path =
    path
    |> String.split_on_char '/'
    |> List.filter (fun x -> String.length x > 0) in

  match meth, path with
  | `GET, [] | `GET, [""] -> handle_health_check ()
  | `POST, "index" :: [] -> Index_handler.handle ~env ~sw ~deps params.request
  | `POST, "search" :: [] -> Search_handler.handle ~env ~sw ~deps params.request
  | _ -> handle_not_found ()
;;
  
(**) let run ~sw ~host ~port ~env deps =
  let config =
    Server.Config.create (`Tcp (host, port))
  in
  let handler = cors_middleware @@ request_handler ~env ~sw ~deps in
  let server = Server.create ~config handler in
  Server.Command.start ~sw env server
;;

let listen ~sw ~env ~deps =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8080 ~env deps
