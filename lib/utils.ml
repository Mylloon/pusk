exception Any of string

let fmt = Printf.sprintf

type context = { session_id : string }

let load_dotenv =
  (* Load variables *)
  let path = "config/.env" in
  if Sys.file_exists path then Dotenv.export ~path ()
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
