type token =
  | Word of string
  | Number of string
  | Other of char

val to_string : token -> string 

val tokenize : string -> token list
