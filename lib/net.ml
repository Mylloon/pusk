open Cohttp_lwt_unix

let send_post_request url json =
  let uri = Uri.of_string url in
  let headers = Cohttp.Header.init_with "Content-Type" "application/json" in
  let body = Cohttp_lwt.Body.of_string json in
  Lwt.bind (Client.post ~headers ~body uri) (fun (_response, body) ->
      Cohttp_lwt.Body.to_string body)
;;

let execute_request url json =
  let body = send_post_request url json in
  Lwt_main.run body
;;
