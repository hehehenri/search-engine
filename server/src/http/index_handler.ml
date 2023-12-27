type index_payload = {
  url: string
} [@@deriving yojson]

let frequency_table (tokens:Lexer.token list) =
  let acc = Hashtbl.create (List.length tokens) in
  List.fold_left (fun acc token -> 
    let () = match Hashtbl.find_opt acc token with
    | Some value -> Hashtbl.replace acc token (value + 1) 
    | None -> Hashtbl.add acc token 1 in
    acc) acc tokens
;;

let host_of_string string =
  let uri = Uri.of_string string in
  let host = Uri.host uri in

  match host with
  | Some host -> Ok host
  | None -> Error (Response.invalid_payload string)
;;

let handle ~env ~sw ~(deps:Deps.deps) (payload:Piaf.Body.t) =
  let (let*) = Result.bind in

  let* body = Piaf.Body.to_string payload 
    |> Result.map_error (Response.from_error `Bad_request) in
  let body_json = Yojson.Safe.from_string body in
  
  let* { url } = index_payload_of_yojson body_json 
    |> Result.map_error (fun _ -> Response.invalid_payload body) in

  Logs.info (fun m -> m "server.handle_index(url=%s)" url);

  let exception Storage_error of string in

  (* TODO: move the logic somewhere else *)
  let store_tokens uri tokens =
    let frequency_table = frequency_table tokens in

    Hashtbl.iter (fun token frequency -> 
      let open Storage.Token in
      let token = dto_of_token token frequency uri in
      match Storage.Token.insert token deps.storage with
      | Ok () -> ()
      | Error (Storage_error e) -> raise (Storage_error e) 
    ) frequency_table;
  in

  let open Crawler in
  let* host = host_of_string url in
  let documents = traverse ~env ~sw host in
  let documents = DocumentMap.map Lexer.tokenize documents in

  try
    DocumentMap.iter store_tokens documents;
    Ok (Piaf.Response.create `OK)
  with
    Storage_error e -> Error (Response.storage_error e) 
;;

let handle ~env ~sw ~(deps:Deps.deps) (req:Piaf.Request.t) =
  let result = handle ~env ~sw ~deps req.body in
  Response.of_result result
;;
