open Soup

let anchors body =
  let html = parse body in
  let anchors = html $$ "a[href]" |> to_list in
  List.map (R.attribute "href") anchors

let text body =
  let html = parse body in
  let texts = texts html
    |> List.map String.trim
    |> List.filter (fun x -> String.length x > 0) in
  String.concat " " texts 
;;

open Base
let simple_html = {|
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple HTML Boilerplate</title>
  </head>
  <body>
    <h1>Welcome to My Website</h1>

    <p>This is a simple HTML boilerplate with a couple of anchor tags.</p>

    <nav>
      <ul>
        <li><a href="#section1">Section 1</a></li>
        <li><a href="#section2">Section 2</a></li>
      </ul>
    </nav>

    <section id="section1">
      <h2>Section 1</h2>
      <p>This is the content of Section 1.</p>
    </section>

    <section id="section2">
      <h2>Section 2</h2>
      <p>This is the content of Section 2.</p>
    </section>
  </body>
  </html>
|} 

let%test_unit "Parser.texts" =
  let expected =
    "Simple HTML Boilerplate " ^
    "Welcome to My Website " ^
    "This is a simple HTML boilerplate with a couple of anchor tags. " ^
    "Section 1 " ^
    "Section 2 " ^
    "Section 1 " ^
    "This is the content of Section 1. " ^
    "Section 2 " ^
    "This is the content of Section 2."
  in
  [%test_eq: string] expected (text simple_html)

let%test_unit "Parser.anchors" = 
  [%test_eq: string list] ["#section1"; "#section2"] (anchors simple_html)
