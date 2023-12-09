open Soup

let anchors body =
  let html = parse body in
  let anchors = html $$ "a[href]" |> to_list in
  List.map (R.attribute "href") anchors

let parse_html_file path =
  let html = read_file path in
  let soup = parse html in
  texts soup |> String.concat ""
