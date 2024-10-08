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
    | it :: [] -> it
    | _ -> raise (Any "Too many elements found as the username input")
  in
  (* Insert the username *)
  send_keys session_id input_username creds.username;
  Unix.sleep 2;
  send_keys session_id input_username Keys.return;
  Unix.sleep 6
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
    | it :: [] -> Some it
    | _ -> raise (Any "Too many elements found as the password input")
  in
  match input_password with
  | Some input ->
    (* Insert password *)
    send_keys session_id input creds.password;
    Unix.sleep 2;
    send_keys session_id input Keys.return;
    Unix.sleep 6
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
  Unix.sleep 2;
  send_keys session_id input Keys.return;
  Unix.sleep 10
;;

let login_twitter ctx username password secret =
  if ctx.debug then print_endline "Login to twitter...";
  (* Navigate to login page and wait for page loaded*)
  ignore (navigate ctx.session_id "https://twitter.com/i/flow/login");
  Unix.sleep 5;
  let creds = { username; password } in
  (* Insert the username *)
  if ctx.debug then print_endline "Type username...";
  inject_username ctx.session_id creds;
  (* Find password input *)
  if ctx.debug then print_endline "Type password...";
  inject_password ctx.session_id creds;
  (* Detection and injection of 2FA code if needed *)
  match find ctx.session_id (CSS "input[name='text']") with
  | [] -> print_endline "Doesn't use 2FA as no input found"
  | it :: [] ->
    if ctx.debug then print_endline "Type 2FA code...";
    inject_2fa ctx.session_id secret it
  | _ -> raise (Any "Too many elements found as 2FA input")
;;

let go_to_profile ctx =
  if ctx.debug then print_endline "Locate profile button...";
  let profile_button =
    match find ctx.session_id (XPath "//a[@data-testid='AppTabBar_Profile_Link']") with
    | [] -> raise (Any (fmt "Profile button not found"))
    | it :: [] -> it
    | _ -> raise (Any "Too many profile button found")
  in
  if ctx.debug then print_endline "Navigate to user replies...";
  ignore
    (navigate
       ctx.session_id
       (fmt
          "https://twitter.com%s/with_replies"
          (get_attribute ctx.session_id profile_button "href")));
  Unix.sleep 8
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
            Core.Time_float.of_string_with_utc_offset
              (get_attribute ctx.session_id date "datetime")
          in
          Float.to_int
            (Core.Time_float.Span.to_sec (Core.Time_float.to_span_since_epoch time)))
        dates
    in
    (* Returns the most recent date *)
    Some (List.fold_left max min_int datetimes)
;;

let tweet ctx msg =
  ignore (navigate ctx.session_id "https://twitter.com/home");
  Unix.sleep 4;
  let tweet_area =
    match find ctx.session_id (CSS "div[data-testid='tweetTextarea_0']") with
    | [] -> raise (Any (fmt "Tweet area not found"))
    | it :: [] -> it
    | _ -> raise (Any "Too many tweet areas found")
  in
  send_keys ctx.session_id tweet_area msg;
  Unix.sleep 2;
  let send_tweet_button =
    match find ctx.session_id (XPath "//button[@data-testid='tweetButtonInline']") with
    | [] -> raise (Any (fmt "Tweet button not found"))
    | it :: [] -> it
    | _ -> raise (Any "Too many tweet button found")
  in
  (* We need first to click somewhere on the page to be able to interact with it *)
  click_somewhere ctx.session_id 800 200;
  Unix.sleep 2;
  click ctx.session_id send_tweet_button;
  Unix.sleep 8
;;
