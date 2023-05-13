open Pusk.Net
open Pusk.Utils

let login_twitter ctx _username _password =
  (* Navigate to login page *)
  ignore (navigate ctx.session_id "https://twitter.com/i/flow/login");
  (* Extra wait to be sure the page is loaded *)
  Unix.sleep 5;
  match
    find
      ctx.session_id
      (XPath
         "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div/div/div/div[5]/label")
  with
  | Some l -> List.iter (fun e -> print_endline (Yojson.Safe.to_string e)) l
  | None -> raise (Any "Username input not found")
;;
