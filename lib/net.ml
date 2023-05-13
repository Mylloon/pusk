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

let get_session =
  let body = execute_request (fmt "%s/session" url) Json.connection_payload in
  print_endline body;
  body
;;

(* match Yojson.Safe.from_string body with
  | _ as e -> print_endline e *)

let close_session id = Lwt_main.run (send_delete_request (fmt "%s/session/%s" url id))
