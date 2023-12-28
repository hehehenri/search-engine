open Rapper_helper

val install_uuid :
  unit ->
  (module CONNECTION) ->
  (unit, [> Caqti_error.call_or_retrieve]) result

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
  
val get_all_tokens :
  unit ->
  (module CONNECTION) ->
  (
    Identifiers.Token.token list,
    [> Caqti_error.call_or_retrieve]
  ) result

val get_term_count :
  term:string ->
  document_url:string ->
  (module CONNECTION) ->
  (int, [> Caqti_error.call_or_retrieve]) result

val get_terms_sum :
  document_url:string ->
  (module CONNECTION) ->
  (int, [> Caqti_error.call_or_retrieve]) result
