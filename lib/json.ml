open Utils

let empty = "{}"

let connection_payload headless =
  fmt
    {|
  {
    "capabilities": {
      "alwaysMatch": {
        "moz:firefoxOptions": {
          "args": [%s]
        }
      }
    }
  }
    |}
    (if headless then "\"-headless\"" else "")
;;

let navigate_payload url = fmt {|
  {
    "url": "%s"
  }
    |} url

let execute_payload src = fmt {|
  {
    "script": "%s",
    "args": []
  }
    |} src

let find_payload strategy value =
  fmt {|
  {
    "using": "%s",
    "value": "%s"
  }
    |} strategy value
;;

let send_keys_payload text =
  fmt
    {|
  {
    "text": "%s",
    "value": %s
  }
    |}
    text
    (Yojson.Safe.to_string
       (`List (List.map (fun str -> `String str) (keys_to_typing text))))
;;

let send_left_click pos_x pos_y =
  fmt
    {|
  {
    "actions": [
      {
        "type": "pointer",
        "id": "mouse",
        "parameters": {
          "pointerType": "mouse"
        },
        "actions": [
          {
            "type": "pointerMove",
            "origin": "viewport",
            "x": %d,
            "y": %d,
            "duration": 0
          },
          {
            "type": "pointerDown",
            "button": 0
          },
          {
            "type": "pause",
            "duration": 100
          },
          {
            "type": "pointerUp",
            "button": 0
          }
        ]
      }
    ]
  }
    |}
    pos_x
    pos_y
;;
