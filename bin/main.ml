open Pusk.Net
open Pusk.Drivers
open Pusk.Utils

exception Any of string

let start driver =
  let name_driver = prepare driver in
  let data_driver = run_process name_driver [] in
  let session_id = get_session () in
  data_driver, session_id
;;

let stop (driver_process, session_id) =
  if not (close_session session_id) then print_endline "Can't close the session";
  stop_process driver_process
;;

let main session_id =
  (* Load credentials *)
  load_dotenv;
  let username, password =
    match Sys.getenv_opt "TWITTER_USERNAME", Sys.getenv_opt "TWITTER_PASSWORD" with
    | Some u, Some p -> u, p
    | None, None -> raise (Any "Username and password not set")
    | None, Some _ -> raise (Any "Username not set")
    | Some _, None -> raise (Any "Password not set")
  in
  (* Navigate to login page *)
  ignore (navigate "https://twitter.com/i/flow/login" session_id);
  (* Extra wait to be sure the page is loaded *)
  Unix.sleep 5;
  (* DEBUG *)
  print_endline (fmt "%s:%s" username password)
;;

let () =
  let data = start (Gecko "0.33.0") in
  (try main (snd data) with
  | Any why -> print_endline why);
  stop data
;;
