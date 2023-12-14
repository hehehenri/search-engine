open Rapper_helper

val create_tokens_table :
  unit ->
  (module CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve]) result

val insert_token :
  content:string ->
  kind:string ->
  occurrences:int ->
  document_url:string ->
  (module Rapper_helper.CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve]) result
  
