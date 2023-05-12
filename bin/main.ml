open Pusk.Utils
open Pusk.Selenium_init

let () =
  (* Selenium *)
  let version_selenium = "4.9.0" in
  let selenium = fmt "selenium-%s.jar" version_selenium in
  if not (Sys.file_exists selenium) then Lwt_main.run (download_selenium version_selenium);
  (* Gecko Driver *)
  let driver = fmt "geckodriver" in
  if not (Sys.file_exists driver)
  then (
    let version_driver = "0.33.0" in
    let archive = fmt "./gecko-%s.tar.gz" version_driver in
    Lwt_main.run (download_gecko_driver version_driver archive);
    let _ = Sys.command (fmt "tar xvzf %s" archive) in
    ());
  let selenium_pid =
    run_program_in_background "java" [ fmt "-jar %s" selenium; "standalone" ]
  in
  print_endline (fmt "Java running in %d" selenium_pid);
  let closed_pid, _ = Unix.waitpid [] selenium_pid in
  if not (closed_pid = selenium_pid)
  then print_endline "WTF???"
  else print_endline (fmt "Program %d closed!" closed_pid)
;;
