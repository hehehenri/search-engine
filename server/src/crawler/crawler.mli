module DocumentMap : Map.S with type key = Uri.t

val traverse : 
  env:Eio_unix.Stdenv.base -> 
  sw:Eio.Switch.t ->
  host:string -> 
  string DocumentMap.t
