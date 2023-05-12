open Lwt.Syntax
open Cohttp_lwt
open Cohttp_lwt_unix

let fmt = Printf.sprintf

let rec download uri dest =
  let* response, body = Client.get uri in
  let status = Response.status response in
  let code = Cohttp.Code.code_of_status status in
  if Cohttp.Code.is_redirection code
  then (
    let headers = Response.headers response in
    match Cohttp.Header.get headers "location" with
    | Some url ->
      let uri = Uri.of_string url in
      let redirect_url = Uri.resolve "" uri uri in
      download redirect_url dest
    | None -> Lwt.fail_with "Redirect location not found")
  else if Cohttp.Code.is_success code
  then (
    print_endline "Downloading...";
    let stream = Body.to_stream body in
    let res =
      Lwt_io.with_file ~mode:Lwt_io.output dest (fun chan ->
          Lwt_stream.iter_s (Lwt_io.write chan) stream)
    in
    let* () = res in
    print_endline "Download done!";
    Lwt.return_unit)
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
