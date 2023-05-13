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
