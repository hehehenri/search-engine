open Soup

let parse_html_file path =
  let html = read_file path in
  let soup = parse html in
  texts soup |> String.concat ""
