open Pusk.Net
open Pusk.Utils

type credentials =
  { username : string
  ; password : string
  }

let inject_username session_id way creds =
  (* Find username input *)
  let xpath =
    match way with
    | 0 ->
      XPath
        "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div/div/div/div[5]/label/div/div[2]/div/input"
    | 1 ->
      XPath
        "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[1]/div/div[2]/label/div/div[2]/div/input"
    | _ -> raise (Any "Unknown page to use for injecting username")
  in
  let input_username =
    match find session_id xpath with
    | [] -> raise (Any (fmt "Username input not found (page %d)" way))
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many element found as the username input")
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
    match
      find
        session_id
        (XPath
           "/html/body/div[1]/div/div/div[1]/div/div/div/div/div/div/div[2]/div[2]/div/div/div[2]/div[2]/div[1]/div/div/div[3]/div/label/div/div[2]/div[1]/input")
    with
    | [] ->
      (* Retry to inject username with the second page *)
      inject_username session_id 1 creds;
      _inject_password session_id creds (try_count - 1);
      None
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many element found as the password input")
      else Some (List.nth l 0)
  in
  match input_password with
  | Some input ->
    (* Insert password *)
    send_keys session_id input creds.password;
    Unix.sleep 1;
    send_keys session_id input Keys.return;
    Unix.sleep 5
  | None -> ()
;;

let inject_password session_id creds = _inject_password session_id creds 1

let inject_2fa _session_id secret _entry =
  let _code =
    match secret with
    | Some seed -> Twostep.TOTP.code ~secret:seed ()
    | None -> raise (Any "No TOTP code given, but TOTP required")
  in
  ()
;;

let login_twitter ctx username password secret =
  (* Navigate to login page and wait for page loaded*)
  ignore (navigate ctx.session_id "https://twitter.com/i/flow/login");
  Unix.sleep 5;
  let creds = { username; password } in
  (* Insert the username *)
  inject_username ctx.session_id 0 creds;
  (* Find password input *)
  inject_password ctx.session_id creds;
  (* Detection of 2FA *)
  match find ctx.session_id (XPath "XPATH_TOTP") with
  | [] -> ()
  | _ as l ->
    if List.length l > 1
    then raise (Any "Too many element found as the username input")
    else inject_2fa ctx.session_id secret (List.nth l 0)
;;
