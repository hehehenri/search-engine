val handle :
  env:Eio_unix.Stdenv.base ->
  sw:Eio.Switch.t ->
  deps:Deps.t -> 
  Piaf.Request.t ->
  Piaf.Response.t
