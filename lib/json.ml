open Utils

let connection_payload =
  {|
  {
    "capabilities": {
      "alwaysMatch": {
        "moz:firefoxOptions": {
          "args": ["-headless"]
        }
      }
    }
  }
  |}
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
