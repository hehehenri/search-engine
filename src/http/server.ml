open Piaf

let handle_health_check () =
  Logs.info (fun m -> m "server.handle_health_check");
  let body = "Status: Health" in
  Response.of_string ~body `OK

let handle_not_found () = 
  Logs.info (fun m -> m "server.handle_not_found");
  Response.of_string ~body:"not found" `Not_found

let frequency_table (tokens:Lexer.token list) =
  let acc = Hashtbl.create (List.length tokens) in
  List.fold_left (fun acc token -> 
    let () = match Hashtbl.find_opt acc token with
    | Some value -> Hashtbl.replace acc token (value + 1) 
    | None -> Hashtbl.add acc token 0 in
    acc) acc tokens
;;

module ResponseError = struct
  let create ~message ~status =
    Logs.err (fun m -> m "request error: %s" message);
    Response.of_string ~body:message status

  let from_err ~status err =
    let message = Error.to_string err in
    create ~message ~status

  let invalid_payload payload =
    let message = Printf.sprintf "invalid payload: %s" payload in
    create ~message ~status:`Bad_request
end

let response_of_result response =
  match response with
  | Ok response -> response
  | Error response -> response
;;

type index_payload = {
  uri: string
} [@@deriving yojson]

(* TODO: should I add the env and sw to the deps? *)
let handle_index ~env ~sw ~(deps:Deps.deps) (payload:Body.t) =
  let (let*) = Result.bind in

  let* body = Body.to_string payload 
    |> Result.map_error (ResponseError.from_err ~status:`Bad_request) in
  let body_json = Yojson.Safe.from_string body in
  
  let* { uri } = index_payload_of_yojson body_json 
    |> Result.map_error (fun _ -> ResponseError.invalid_payload body) in

  Logs.info (fun m -> m "server.handle_index(uri=%s)" uri);

  (* TODO: move the logic somewhere else *)
  let store_document uri tokens =
    let frequency_table = frequency_table tokens in

    Hashtbl.iter (fun token frequency -> 
      let open Storage.Token in
      let token = dto_of_token token frequency uri in
      Storage.Token.insert token deps.storage; 
    ) frequency_table;
  in

  let open Crawler in
  let documents = traverse ~env ~sw uri in
  let documents = DocumentMap.map Lexer.tokenize documents in
  DocumentMap.iter store_document documents;
  
  Ok (Response.create `OK)
;;

let handle_index ~env ~sw ~(deps:Deps.deps) (payload:Body.t) =
  let result = handle_index ~env ~sw ~deps payload in
  response_of_result result
;;

let request_handler ~env ~sw ~(deps:Deps.deps) (params : Request_info.t Server.ctx) =
  let meth = params.request.meth in
  let path = 
      params.request
    |> Request.uri
    |> Uri.path in


  Logs.info (fun m ->
    let meth = Method.to_string meth in
    m "Request %s: %s" meth path);

  let path =
    path
    |> String.split_on_char '/'
    |> List.filter (fun x -> String.length x > 0) in

  match meth, path with
  | `GET, [] | `GET, [""] -> handle_health_check ()
  | `POST, "index" :: [] -> handle_index ~env ~sw ~deps params.request.body
  | _ -> handle_not_found ()

let run ~sw ~host ~port ~env deps =
  let config =
    Server.Config.create (`Tcp (host, port))
  in
  let handler = request_handler ~env ~sw ~deps in
  let server = Server.create ~config handler in
  let command = Server.Command.start ~sw env server in
  command

let listen ~sw ~env ~deps =
  let host = Eio.Net.Ipaddr.V4.loopback in
  run ~sw ~host ~port:8080 ~env deps
