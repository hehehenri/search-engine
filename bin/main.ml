let () = Eio_main.run(fun env ->
  let _documents = Crawler.traverse env "https://henr.in/" in
  ()
)
