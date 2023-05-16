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
    | None -> raise (Any "Redirect location not found"))
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
    raise
      (Any ("Failed to download file. HTTP status: " ^ Cohttp.Code.string_of_status status))
;;

let download_gecko_driver version output =
  let url =
    format_of_string
      "https://github.com/mozilla/geckodriver/releases/download/v%s/geckodriver-v%s-linux64.tar.gz"
  in
  download (Uri.of_string (fmt url version version)) output
;;

type driver = Gecko of string

let prepare = function
  | Gecko version_driver ->
    let driver = fmt "geckodriver-%s" version_driver in
    if not (Sys.file_exists driver)
    then (
      let archive = fmt "./gecko-%s.tar.gz" version_driver in
      Lwt_main.run (download_gecko_driver version_driver archive);
      (* TODO: Use native version instead of relying on Unix tools *)
      ignore (Sys.command (fmt "tar xvzf %s" archive));
      ignore (Sys.command (fmt "mv geckodriver %s" driver));
      ignore (Sys.command (fmt "rm %s" archive)));
    driver
;;

let run_process path args =
  let command = fmt "./%s" path in
  (* TODO: Log into a log/ folder
   * + create file based on time of run *)
  let output_file = fmt "%s-output.txt" path in
  let out_channel = open_out output_file in
  let output_fd = Unix.descr_of_out_channel out_channel in
  let pid =
    Unix.create_process command (Array.of_list args) output_fd output_fd output_fd
  in
  Unix.sleep 1;
  out_channel, pid
;;

let stop_process data =
  let out_channel, pid = data in
  close_out out_channel;
  Unix.kill pid Sys.sigterm
;;
