# Pusk

Send a tweet to prevent Twitter from closing your account.

## How to use?

## With Docker

You can use this dockercompose template:

```yaml
version: "3.9"

services:
  pusk:
    image: git.mylloon.fr/Anri/pusk:latest
    container_name: Pusk
    environment:
      - TWITTER_USERNAME=yourusername # not your mail
      - TWITTER_PASSWORD=yourpassword
      - TWITTER_TOTP=yourseed # optional if you don't have 2fa
      - PUSK_DEBUG=FALSE # optional
    restart: unless-stopped
```

## Local

- You will need these dependencies:

  ```sh
  $ opam install cohttp-lwt-unix tls-lwt dotenv twostep lwt_ssl yojson
  ```

- Populate your credentials in [config/.env](./config/.env)
- Then you can run the bot with:

  ```sh
  $ dune exec pusk
  ```

## Name history

Derived from Elon's name :D. Thanks, Elon, for destroying Twitter.
