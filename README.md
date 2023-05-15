# Pusk

<<<<<<< HEAD
## Requirements

```opam
$ opam switch list
#  switch   compiler                    description
→  default  ocaml-base-compiler.4.14.1  default
```

### Install dependencies

```sh
dune describe external-lib-deps | sed -n '/external_deps/,/))/p' | sed -e 's/[()]//g' -e 's/required//g' -e '/external_deps/d' | xargs -n1 opam install -y
```

## Name history

Derived from Elon's name :D. Thanks, Elon, for destroying Twitter.

## TODO list

=======
>>>>>>> parent of 658ef57 (Add a command who install dependencies based on dune-project)
- [x] Download a driver
- [x] Run a driver in background during the life of the app
- [x] [Figuring out how to use drivers](https://w3c.github.io/webdriver/#endpoints)
- [x] Login to Twitter.com
- [x] Check if latest tweet of user is more or less old than 30 days
- [x] Then tweet if needed something like "Don't delete my account please"
- [x] Close everything properly
- [ ] Maybe create a docker image for easy deployment?

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
