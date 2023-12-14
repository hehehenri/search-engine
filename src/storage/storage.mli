type storage
type t = storage

val connect : 
  env:Caqti_eio.stdenv -> 
  sw:Eio.Switch.t -> 
  Uri.t -> storage

module Token : sig
  type token = {
    content: string;
    kind: [`Word | `Number | `Other];
    occurrences: int;
    document_url: string;
  }

  val insert : token -> storage -> unit
end
