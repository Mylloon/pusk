open Pusk.Net
open Pusk.Utils

let login_twitter ctx username password =
  (* Navigate to login page and wait for page loaded*)
  ignore (navigate ctx.session_id "https://twitter.com/i/flow/login");
  Unix.sleep 5;
  (* Find username input *)
  let input_username =
    match
      find
        ctx.session_id
        (XPath
           "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div/div/div/div[5]/label/div/div[2]/div/input")
    with
    | [] -> raise (Any "Username input not found")
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many element found as the username input")
      else List.nth l 0
  in
  (* Insert the username *)
  send_keys ctx.session_id input_username username;
  Unix.sleep 1;
  send_keys ctx.session_id input_username Keys.return;
  Unix.sleep 3;
  (* Find password input *)
  let input_password =
    match
      find
        ctx.session_id
        (XPath
           "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[1]/div/div/div[3]/div/label/div/div[2]/div[1]/input")
    with
    | [] -> raise (Any "Password input not found")
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many element found as the password input")
      else List.nth l 0
  in
  (* Insert password *)
  send_keys ctx.session_id input_password password;
  Unix.sleep 1;
  send_keys ctx.session_id input_password Keys.return;
  Unix.sleep 5
;;