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
      (* NOTE: I think this is only when a email is first sent, so the second
       * injection NEED to be a username (or phone number)
       *
       * Maybe allow user to provides us with username and email and use email
       * by default and fallback to username in the second attempt *)
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

let go_to_profile ctx =
  let profile_button =
    match find ctx.session_id (XPath "//a[@data-testid='AppTabBar_Profile_Link']") with
    | [] -> raise (Any (fmt "Profile button not found"))
    | _ as l ->
      if List.length l > 1
      then raise (Any "Too many profile button found")
      else List.nth l 0
  in
  ignore
    (navigate
       ctx.session_id
       (fmt
          "https://twitter.com%s/with_replies"
          (get_attribute ctx.session_id profile_button "href")));
  Unix.sleep 4
;;

let find_latest_tweet ctx =
  match find ctx.session_id (XPath "//article[@data-testid='tweet']") with
  | [] -> None
  | _ as tweets ->
    (* Get dates attached to each tweets *)
    let dates =
      (* When a tweet is a RT, two dates are attached *)
      List.flatten
        (List.map
           (fun tweet ->
             match find_in_element ctx.session_id (CSS "time[datetime]") tweet with
             | [] -> raise (Any (fmt "No dates found for tweet '%s'" tweet))
             | _ as l -> l)
           tweets)
    in
    (* Turn datetime from ISO 8601 format to epoch int *)
    let datetimes =
      List.map
        (fun date ->
          let time =
            Core.Time.of_string_with_utc_offset
              (get_attribute ctx.session_id date "datetime")
          in
          Core.Time.to_span_since_epoch time |> Core.Time.Span.to_sec |> Float.to_int)
        dates
    in
    Some (List.fold_left max min_int datetimes)
;;
