let input_string = Parser.parse_html_file "./input.html"
let tokens = Lexer.tokenize input_string

let _ = List.map (fun token -> let token = Lexer.to_string token in Printf.sprintf "%s\n" token) tokens
  |> List.map print_string
