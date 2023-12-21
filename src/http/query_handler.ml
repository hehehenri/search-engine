type payload = {
  query: string;
  uri: string;
} [@@deriving yojson]

let handle ~env ~sw ~(deps:Deps.t) (req:Piaf.Request.t) =
  let (let*) = Result.bind in

  let* body = Piaf.Body.to_string req.body 
    |> Result.map_error (Response.from_error `Bad_request) in
  let body_json = Yojson.Safe.from_string body in

  let* { query; uri } = payload_of_yojson body_json
    |> Result.map_error (fun _ -> Response.invalid_payload body) in

  let query_token = Lexer.tokenize query in

  Ok (Piaf.Response.create Piaf.Status.(`OK))
;;

let handle ~env ~sw ~(deps:Deps.t) req =
  let result = handle ~env ~sw ~deps req in
  Response.of_result result 
