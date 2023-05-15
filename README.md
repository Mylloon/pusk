# Pusk

## Requirements

```opam
$ opam switch list
#  switch   compiler                    description
→  default  ocaml-base-compiler.4.14.1  default
```

```sh
$ opam install cohttp-lwt-unix tls-lwt dotenv twostep
```

## Name history

Derived from Elon's name :D. Thanks, Elon, for destroying Twitter.

## TODO list

- [x] Download a driver
- [x] Run a driver in background during the life of the app
- [x] [Figuring out how to use drivers](https://w3c.github.io/webdriver/#endpoints)
- [x] Login to Twitter.com
- [x] Check if latest tweet of user is more or less old than 30 days
- [x] Then tweet if needed something like "Don't delete my account please"
- [x] Close everything properly
- [ ] Maybe create a docker image for easy deployment?
