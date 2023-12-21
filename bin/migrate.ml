let setup_log () =
 Logs_threaded.enable ();
 Fmt_tty.setup_std_outputs ();
 Logs.set_level ~all:true (Some Info);
 Logs.set_reporter (Logs_fmt.reporter ())
;;


let () =
  let db_uri = Uri.of_string "postgresql://postgres:password@localhost:5432/index" in
  setup_log ();

  Eio_main.run (fun env ->
    Eio.Switch.run (fun sw -> 
    Storage.migrate ~env ~sw db_uri
  ))
