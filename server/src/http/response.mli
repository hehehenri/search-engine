val of_result : ('a, 'a) result -> 'a  
val from_error : Piaf.Status.t -> Piaf.Error.t -> Piaf.Response.t
val invalid_payload : string -> Piaf.Response.t
val storage_error : string -> Piaf.Response.t
