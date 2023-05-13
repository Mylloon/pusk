open Cohttp_lwt_unix
open Utils

let driver_url = "http://127.0.0.1:4444/session"

let send_post_request url json =
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body = Cohttp_lwt.Body.of_string json in
  Lwt.bind
    (Client.post ~headers ~body (Uri.of_string url))
    (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let send_delete_request url =
  Lwt.bind
    (Client.delete (Uri.of_string url))
    (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let execute_request url json = Lwt_main.run (send_post_request url json)

(* Server MUST be started already *)
let get_session () =
  let response = execute_request (fmt "%s" driver_url) Json.connection_payload in
  match Yojson.Safe.from_string response with
  | `Assoc fields ->
    let value = List.assoc "value" fields in
    let rec find_session_id = function
      | ("sessionId", `String session_id) :: _ -> session_id
      | _ :: rest -> find_session_id rest
      | [] -> failwith "Session ID not found"
    in
    find_session_id (Yojson.Safe.Util.to_assoc value)
  | _ -> failwith "Invalid JSON"
;;

let close_session id =
  Lwt_main.run (send_delete_request (fmt "%s/%s" driver_url id)) = "{\"value\":null}"
;;

let navigate url session_id =
  execute_request (fmt "%s/%s/url" driver_url session_id) (Json.navigate_payload url)
;;
