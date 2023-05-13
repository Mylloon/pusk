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
