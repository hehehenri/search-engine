type pool = ((module Rapper_helper.CONNECTION), Caqti_error.t) Caqti_eio.Pool.t
type storage = | Storage of { pool : pool }
type t = storage

type error = | Storage_error of string

let use pool f =
  match Caqti_eio.Pool.use f pool with
  | Ok v -> Ok v
  | Error e -> Error (Storage_error (Caqti_error.show e))
;;

let connect ~env ~sw uri =
  let stdenv = (env :> Caqti_eio.stdenv) in
  let pool = Caqti_eio_unix.connect_pool ~stdenv ~sw uri in
  match pool with
  | Ok pool -> 
    Logs.info (fun m -> m "Connected to storage successfully"); 
    Storage { pool }
  | Error e -> 
    Logs.err (fun e -> e "Failed to connect to storage"); 
    failwith (Caqti_error.show e)
;;

let migrate ~env ~sw uri =
  let Storage { pool } = connect ~env ~sw uri in 
  let (let*) = Result.bind in

  let result = use pool @@ fun conn ->
    let* () = Query.install_uuid () conn in
    Logs.info (fun m -> m "Migrations: installed uuid extension");
    let* () = Query.create_tokens_table () conn in
    Logs.info (fun m -> m "Migrations: created tokens table");
    Ok ()
  in

  match result with
  | Ok () -> Logs.info (fun m -> m "Migrations: Done.");
  | Error (Storage_error e) -> Logs.err (fun m -> m "Migrations: %s" e)
;;

module Token = struct
  type token = {
    content: string;
    kind: [`Word | `Number | `Other];
    occurrences: int;
    document_url: string;
  } ;;


  (* TODO: ain't no way i'll name this a token "dto". think harder *)
  let dto_of_token token occurrences document_url =
    let open Lexer in
    match token with
    | Word content ->
      { content; kind=`Word; occurrences; document_url; }
    | Number content ->
      { content; kind=`Number; occurrences; document_url; }
    | Other char ->
      { content=(Char.escaped char) ; kind=`Other; occurrences; document_url; }
  ;;
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
