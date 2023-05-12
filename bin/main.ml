open Pusk.Utils
open Pusk.Selenium_init

let main = ()

let () =
  let selenium = prepare "4.9.0" (Gecko "0.33.0") in
  let selenium_pid = run selenium in
  print_endline (fmt "Java running in %d" selenium_pid);
  main;
  let closed_pid = close selenium_pid in
  print_endline (fmt "Program %d closed!" closed_pid)
;;
