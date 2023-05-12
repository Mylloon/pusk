open Lwt.Syntax
open Cohttp_lwt
open Cohttp_lwt_unix

let fmt = Printf.sprintf

let download uri dest =
  let* response, body = Client.get uri in
  let status = Response.status response in
  if Cohttp.Code.code_of_status status = 302
  then (
    print_endline (fmt "\nDownloading %s ..." (Uri.to_string uri));
    let stream = Body.to_stream body in
    Lwt_io.with_file ~mode:Lwt_io.output dest (fun chan ->
        Lwt_stream.iter_s (Lwt_io.write chan) stream))
  else
    Lwt.fail_with
      ("Failed to download file. HTTP status: " ^ Cohttp.Code.string_of_status status)
;;

let download_selenium version =
  let url =
    format_of_string
      "https://github.com/SeleniumHQ/selenium/releases/download/selenium-%s/selenium-server-%s.jar"
  in
  download (Uri.of_string (fmt url version version)) (fmt "./selenium-%s.jar" version)
;;

let () = Lwt_main.run (download_selenium "4.9.0")
