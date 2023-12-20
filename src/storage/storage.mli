type storage
type t = storage

val connect : 
  env:Eio_unix.Stdenv.base -> 
  sw:Eio.Switch.t -> 
  Uri.t -> storage

module Token : sig
  type token = {
    content: string;
    kind: [`Word | `Number | `Other];
    occurrences: int;
    document_url: string;
  }

  val dto_of_token : Lexer.token -> int -> string -> token 

  val insert : token -> storage -> unit

  val get_all : storage -> Identifiers.Token.token list
end
