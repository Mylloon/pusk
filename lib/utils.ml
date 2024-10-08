exception Any of string

let fmt = Printf.sprintf

type context =
  { session_id : string
  ; debug : bool
  ; hashtag : bool
  }

let load_dotenv =
  (* Load variables *)
  let path = "config/.env" in
  if Sys.file_exists path then Dotenv.export ~path ()
;;

let boolean_env variable =
  match Sys.getenv_opt variable with
  | Some boolean -> String.lowercase_ascii boolean = "true"
  | None -> false
;;

let keys_to_typing str =
  let rec aux acc = function
    | 0 -> acc
    | n -> aux (String.sub str (n - 1) 1 :: acc) (n - 1)
  in
  aux [] (String.length str)
;;

module Keys = struct
  let return = "\\ue006"
end
