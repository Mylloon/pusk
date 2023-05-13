open Pusk.Net
open Pusk.Drivers

let start driver =
  let name_driver = prepare driver in
  let data_driver = run_process name_driver [] in
  let session_id = get_session () in
  data_driver, session_id
;;

let stop (driver_process, session_id) =
  let data = close_session session_id in
  print_endline data;
  stop_process driver_process
;;

let main () = ()

let () =
  let data = start (Gecko "0.33.0") in
  main ();
  stop data
;;
