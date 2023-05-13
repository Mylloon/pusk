exception Any of string

let fmt = Printf.sprintf

type context = { session_id : string }

let load_dotenv =
  (* Load variables *)
  let path = "config/.env" in
  if Sys.file_exists path then Dotenv.export ~path ()
;;
