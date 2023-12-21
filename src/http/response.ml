open Piaf

let of_result response =
  match response with
  | Ok response -> response
  | Error response -> response
;;

let from_error status err =
  let message = Error.to_string err in
  let body = Body.of_string message in

  Logs.err (fun m -> m "Request error: %s" message);
  Piaf.Response.create ~body status

let invalid_payload payload =
  let message = Printf.sprintf "Invalid payload: %s" payload in
  let body = Body.of_string message in

  Logs.err (fun m -> m "%s" message);
  Piaf.Response.create ~body `Bad_request

let storage_error error =
  let message = Printf.sprintf "Storage error: %s" error in
  let body = Body.of_string message in

  Logs.err (fun m -> m "%s" message);
  Piaf.Response.create ~ body `Internal_server_error
