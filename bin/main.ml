let build_deps ~env ~sw uri =
 let uri = Uri.of_string uri in
 let storage = Storage.connect ~sw ~env uri in
 Deps.{ storage }
;;

let setup_log () =
 Logs_threaded.enable ();
 Fmt_tty.setup_std_outputs ();
 Logs.set_level ~all:true (Some Info);
 Logs.set_reporter (Logs_fmt.reporter ())

let () =
 (* TODO: get from .env *)
 let uri = "postgresql://postgres:password@localhost:5432/index" in
 setup_log ();
 
 Eio_main.run(fun env ->
  Eio.Switch.run (fun sw -> 
   let deps = build_deps ~env ~sw uri in
   let _command = Http.Server.listen ~sw ~env ~deps in
  ()
 ))
