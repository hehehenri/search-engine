type payload = {
  query: string;
  uri: string;
} [@@deriving yojson]

let handle ~env:_ ~sw:_ ~(deps:Deps.t) (req:Piaf.Request.t) =
  let _ = deps in
  let (let*) = Result.bind in

  let* body = Piaf.Body.to_string req.body 
    |> Result.map_error (Response.from_error `Bad_request) in
  let body_json = Yojson.Safe.from_string body in

  let* { query; uri } = payload_of_yojson body_json
    |> Result.map_error (fun _ -> Response.invalid_payload body) in

  let _ = uri in
  let query_tokens = Lexer.tokenize query in

  print_endline @@ [%derive.show: Lexer.token list] query_tokens;

  Ok (Piaf.Response.create `OK)
;;

let handle ~env ~sw ~(deps:Deps.t) req =
  let result = handle ~env ~sw ~deps req in
  Response.of_result result 
