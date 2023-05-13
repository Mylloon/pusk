open Pusk.Utils
open Pusk
open Pusk.Net
open Pusk.Drivers

let main pid =
  print_endline (fmt "Driver running as %d" pid);
  let body = execute_request "http://localhost:4444/session" Json.connection_payload in
  print_endline body
;;

let () =
  let driver = prepare (Gecko "0.33.0") in
  let driver_process = run_process driver [] in
  main (snd driver_process);
  stop_process driver_process
;;
