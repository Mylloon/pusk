open Pusk.Utils
open Pusk
open Pusk.Net
open Pusk.Drivers

let main =
  let body = execute_request "http://localhost:4444/session" Json.connection_payload in
  print_endline body
;;

let () =
  let driver = prepare (Gecko "0.33.0") in
  let driver_pid = run driver [] in
  print_endline (fmt "Driver running as %d" driver_pid);
  main
;;
