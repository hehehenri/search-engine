open Piaf

type request = Request_info.t Server.ctx

val handle_health_check : Response.t

val handle_not_found : Response.t 

val handle_index : string -> Response.t

val request_handler : Request_info.t Server.Handler.t

val run :
  sw:Eio.Switch.t ->
  host:Eio.Net.Ipaddr.v4v6 ->
  port:int -> 
  Eio_unix.Stdenv.base ->
  Server.Command.t

val serve : sw:Eio.Switch.t -> Eio_unix.Stdenv.base -> Server.Command.t
