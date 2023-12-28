type storage
type t = storage
type error = | Storage_error of string

val connect : 
  env:Eio_unix.Stdenv.base -> 
  sw:Eio.Switch.t -> 
  Uri.t -> storage

val migrate :
  env:Eio_unix.Stdenv.base -> 
  sw:Eio.Switch.t -> 
  Uri.t ->
  unit

module Token : sig
  type token = {
    content: string;
    kind: [`Word | `Number | `Other];
    occurrences: int;
    document_url: Uri.t;
  }

  val dto_of_token : Lexer.token -> int -> Uri.t -> token 

  val insert : token -> storage -> (unit, error) result

  val get_all : storage -> (Identifiers.Token.token list, error) result
end

module Document : sig
  val get_term_count :
    storage ->
    document_url:string ->
    term:string ->
    (int, error) result

  val get_terms_sum :
    storage ->
    document_url:string ->
    (int, error) result
end
