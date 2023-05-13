open Pusk.Utils
open Pusk.Net
open Pusk.Drivers

let main =
  let json_payload =
    {|
    {
      "capabilities": {
        "alwaysMatch": {
          "moz:firefoxOptions": {
            "args": ["-headless"]
          }
        }
      }
    }
    |}
  in
  let body = send_post_request "http://localhost:4444/session" json_payload in
  print_endline (Lwt_main.run body)
;;

let () =
  let driver = prepare (Gecko "0.33.0") in
  let driver_pid = run driver [] in
  print_endline (fmt "Driver running as %d" driver_pid);
  main;
  let closed_pid = close driver_pid in
  print_endline (fmt "Program %d closed!" closed_pid)
;;
