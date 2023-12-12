module DocumentMap : Map.S with type key = string

val traverse : Eio_unix.Stdenv.base -> string -> string DocumentMap.t
