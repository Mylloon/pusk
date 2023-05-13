# Pusk

**WIP: It's not working**

TODO: (as you can see, nothing has been done yet!)

- [x] Download a driver
- [x] Run a driver in background during the life of the app
- [x] [Figuring out how to use drivers](https://w3c.github.io/webdriver/#endpoints)
- [ ] Login to Twitter.com
- [ ] Check if latest tweet of user is more or less old than 30 days
- [ ] Then tweet if needed something like "Don't delete my account please"
- [x] Close everything properly
- [ ] Maybe create a docker image for easy deployment?

## Requirements

```opam
$ opam switch list
#  switch   compiler                    description
→  default  ocaml-base-compiler.4.14.1  default
```

```sh
$ opam install cohttp-lwt-unix tls-lwt dotenv
```

## Name history

Derived from Elon's name :D. Thanks, Elon, for destroying Twitter.
