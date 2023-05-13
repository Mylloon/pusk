open Cohttp_lwt_unix
open Utils

let driver_url = "http://127.0.0.1:4444/session"
let driver id = fmt "%s/%s" driver_url id

let send_post_request url json =
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body = Cohttp_lwt.Body.of_string json in
  Lwt.bind
    (Client.post ~headers ~body (Uri.of_string url))
    (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let send_get_request url =
  Lwt.bind
    (Client.get (Uri.of_string url))
    (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let send_delete_request url =
  Lwt.bind
    (Client.delete (Uri.of_string url))
    (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let execute_post_request url json = Lwt_main.run (send_post_request url json)
let execute_get_request url = Lwt_main.run (send_get_request url)
let execute_delete_request url = Lwt_main.run (send_delete_request url)

(* Server MUST be started already *)
let get_session ?(headless = true) () =
  let response =
    execute_post_request (fmt "%s" driver_url) (Json.connection_payload headless)
  in
  match Yojson.Safe.from_string response with
  | `Assoc fields ->
    let value = List.assoc "value" fields in
    let rec find_session_id = function
      | ("sessionId", `String session_id) :: _ -> session_id
      | _ :: rest -> find_session_id rest
      | [] -> raise (Any "Session ID not found")
    in
    find_session_id (Yojson.Safe.Util.to_assoc value)
  | _ -> raise (Any "get_session | Invalid JSON")
;;

let close_session id = execute_delete_request (driver id) = "{\"value\":null}"

let execute_sync session_id src =
  execute_post_request
    (fmt "%s/execute/sync" (driver session_id))
    (Json.execute_payload src)
;;

type strategy = XPath of string

let get_strategy = function
  | XPath xpath -> "xpath", xpath
;;

let rec wait_for_load session_id =
  let response = execute_sync session_id "return document.readyState" in
  match Yojson.Safe.from_string response with
  | `Assoc fields ->
    (match List.assoc "value" fields with
    | `String res ->
      if not (res = "complete")
      then (
        Unix.sleep 1;
        wait_for_load session_id)
    | _ -> raise (Any "Error when waiting for page to load"))
  | _ -> raise (Any "wait_for_load | Invalid JSON")
;;

let navigate ?(wait = true) session_id url =
  let res =
    execute_post_request (fmt "%s/url" (driver session_id)) (Json.navigate_payload url)
  in
  if wait then wait_for_load session_id;
  res
;;

let screenshot session_id = execute_get_request (fmt "%s/screenshot" (driver session_id))

let find session_id strategy =
  let engine, search = get_strategy strategy in
  let response =
    execute_post_request
      (fmt "%s/elements" (driver session_id))
      (Json.find_payload engine search)
  in
  match Yojson.Safe.from_string response with
  | `Assoc fields ->
    (match List.assoc "value" fields with
    | `List l ->
      List.fold_left
        (fun acc x ->
          match x with
          | `Assoc subfields ->
            List.fold_left
              (fun acc' (_, value) ->
                match value with
                | `String str -> str :: acc'
                | _ -> acc')
              acc
              subfields
          | _ -> acc)
        []
        l
    | _ -> [])
  | _ -> raise (Any "wait_for_load | Invalid JSON")
;;

let send_keys session_id element_id username =
  ignore
    (execute_post_request
       (fmt "%s/element/%s/value" (driver session_id) element_id)
       (Json.send_keys_payload username))
;;
