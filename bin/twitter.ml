open Pusk.Net
open Pusk.Utils

type credentials =
  { username : string
  ; password : string
  }

let inject_username session_id creds =
  (* Find username input *)
  let strat = CSS "input[name='text']" in
  let input_username =
    match find session_id strat with
    | [] -> raise (Any (fmt "Username input not found"))
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many elements found as the username input")
      else List.nth l 0
  in
  (* Insert the username *)
  send_keys session_id input_username creds.username;
  Unix.sleep 1;
  send_keys session_id input_username Keys.return;
  Unix.sleep 3
;;

let rec _inject_password session_id creds try_count =
  if try_count == 0 then raise (Any "Password input not found");
  let input_password =
    match find session_id (CSS "input[name='password']") with
    | [] ->
      (* Retry to inject username with the second page *)
      inject_username session_id creds;
      _inject_password session_id creds (try_count - 1);
      None
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many elements found as the password input")
      else Some (List.nth l 0)
  in
  match input_password with
  | Some input ->
    (* Insert password *)
    send_keys session_id input creds.password;
    Unix.sleep 1;
    send_keys session_id input Keys.return;
    Unix.sleep 3
  | None -> ()
;;

let inject_password session_id creds = _inject_password session_id creds 1

let inject_2fa session_id secret input =
  let code =
    match secret with
    | Some seed -> Twostep.TOTP.code ~secret:seed ()
    | None -> raise (Any "No TOTP code given, but 2FA code required")
  in
  (* Insert 2FA code *)
  send_keys session_id input code;
  Unix.sleep 1;
  send_keys session_id input Keys.return;
  Unix.sleep 5
;;

let login_twitter ctx username password secret =
  (* Navigate to login page and wait for page loaded*)
  ignore (navigate ctx.session_id "https://twitter.com/i/flow/login");
  Unix.sleep 5;
  let creds = { username; password } in
  (* Insert the username *)
  inject_username ctx.session_id creds;
  (* Find password input *)
  inject_password ctx.session_id creds;
  (* Detection and injection of 2FA code if needed *)
  match find ctx.session_id (CSS "input[name='text']") with
  | [] -> print_endline "Doesn't use 2FA as no input found"
  | _ as l ->
    if List.length l > 1
    then raise (Any "Too many elements found as 2FA input")
    else inject_2fa ctx.session_id secret (List.nth l 0)
;;
