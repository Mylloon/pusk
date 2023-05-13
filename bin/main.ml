open Pusk.Net
open Pusk.Drivers

let main =
  let session_id = get_session in
  let body = close_session session_id in
  print_endline body
;;

let () =
  let driver = prepare (Gecko "0.33.0") in
  let driver_process = run_process driver [] in
  main;
  stop_process driver_process
;;
