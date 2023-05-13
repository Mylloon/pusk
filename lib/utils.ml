exception Any of string

let fmt = Printf.sprintf

let load_dotenv =
  (* Load variables *)
  let path = "config/.env" in
  if Sys.file_exists path then Dotenv.export ~path ()
;;
