open Lwt.Syntax
open Cohttp_lwt
open Cohttp_lwt_unix
open Utils

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

let download_gecko_driver version output =
  let url =
    format_of_string
      "https://github.com/mozilla/geckodriver/releases/download/v%s/geckodriver-v%s-linux64.tar.gz"
  in
  download (Uri.of_string (fmt url version version)) output
;;

let run_program_in_background program args =
  let pid = Unix.fork () in
  match pid with
  | 0 ->
    (* Child process *)
    let dev_null = Unix.openfile "/dev/null" [ O_WRONLY ] 0o666 in
    Unix.dup2 dev_null Unix.stdout;
    Unix.dup2 dev_null Unix.stderr;
    Unix.close dev_null;
    Unix.execvp program (Array.of_list (program :: args))
  | _ -> pid (* Parent process *)
;;
