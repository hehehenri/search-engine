 let () = 
  Eio_main.run(fun env ->
    Eio.Std.Switch.run (fun sw -> 
    let _command = Http.Server.serve ~sw env in
    ()
  ))
