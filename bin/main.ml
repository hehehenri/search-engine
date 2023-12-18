let setup_log () =
 Logs_threaded.enable ();
 Fmt_tty.setup_std_outputs ();
 Logs.set_level ~all:true (Some Info);
 Logs.set_reporter (Logs_fmt.reporter ())

let () =
 setup_log ();
 Eio_main.run(fun env ->
  Eio.Std.Switch.run (fun sw -> 
   let _command = Http.Server.serve ~sw env in
  ()
 ))
