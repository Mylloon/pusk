open Cohttp_lwt_unix
open Utils

let url = "http://127.0.0.1:4444"

let send_post_request url json =
  let uri = Uri.of_string url in
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body = Cohttp_lwt.Body.of_string json in
  Lwt.bind (Client.post ~headers ~body uri) (fun (_response, body) ->
      Cohttp_lwt.Body.to_string body)
;;

let send_delete_request url =
  let uri = Uri.of_string url in
  Lwt.bind (Client.delete uri) (fun (_response, body) -> Cohttp_lwt.Body.to_string body)
;;

let execute_request url json =
  let body = send_post_request url json in
  Lwt_main.run body
;;

let get_session () =
  let response = execute_request (fmt "%s/session" url) Json.connection_payload in
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
  Lwt_main.run (send_delete_request (fmt "%s/session/%s" url id)) = "{\"value\":null}"
;;
