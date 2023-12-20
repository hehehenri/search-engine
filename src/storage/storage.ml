exception Storage_error of
  [ Caqti_error.load | Caqti_error.connect | Caqti_error.call_or_retrieve ] ;;

let () =
  Printexc.register_printer (function 
  | Storage_error e -> 
    let message =
      Format.asprintf "Storage_error(%a)" Caqti_error.pp e
    in
    Some message

  | _ -> None)
;;

type pool = ((module Rapper_helper.CONNECTION), Caqti_error.t) Caqti_eio.Pool.t
type storage = | Storage of { pool : pool }
type t = storage

let connect ~env ~sw uri =
  let stdenv = (env :> Caqti_eio.stdenv) in
  let pool = Caqti_eio_unix.connect_pool ~stdenv ~sw uri in
  match pool with
  | Ok pool -> 
    Logs.info (fun m -> m "Connected to storage successfully"); 
    Storage { pool }
  | Error e -> 
    Logs.err (fun e -> e "Failed to connect to storage"); 
    raise @@ Storage_error e
;;

let use pool f =
  match Caqti_eio.Pool.use f pool with
  | Ok v -> v
  | Error e -> raise @@ Storage_error e
;;

module Token = struct
  type token = {
    content: string;
    kind: [`Word | `Number | `Other];
    occurrences: int;
    document_url: string;
  } ;;

  let token_kind token =
    match token.kind with
    | `Word -> "word"
    | `Number -> "number"
    | `Other -> "other"

  let insert token storage =
    let Storage { pool } = storage in
    let { content; occurrences; document_url; _ } = token in
    let kind = token_kind token in

    use pool @@
      fun conn -> 
        Query.insert_token 
          ~content
          ~kind
          ~occurrences
          ~document_url
          conn

  let get_all storage =
    let Storage { pool } = storage in
    use pool @@
      fun conn -> Query.get_all_tokens () conn
end
