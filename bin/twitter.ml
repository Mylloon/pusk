open Pusk.Net
open Pusk.Utils

let login_twitter ctx _username _password =
  (* Navigate to login page *)
  ignore (navigate "https://twitter.com/i/flow/login" ctx.session_id);
  (* Extra wait to be sure the page is loaded *)
  Unix.sleep 5
;;
