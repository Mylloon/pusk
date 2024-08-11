# Pusk ![status-badge](https://git.mylloon.fr/Anri/pusk/badges/workflows/publish.yml/badge.svg)

Send a tweet to prevent Twitter from closing your account, using a webdriver.

## How to use?

## With Docker

You can use this dockercompose template:

```yaml
services:
  pusk:
    image: git.mylloon.fr/anri/pusk:latest
    container_name: Pusk
    environment:
      - TWITTER_USERNAME=yourusername # not your mail
      - TWITTER_PASSWORD=yourpassword # in dockercompose, you need to double $ signs in your password
      - TWITTER_TOTP=yourseed # optional if you don't have 2fa
      - PUSK_DEBUG=FALSE # optional
      - PUSK_HASHTAG=TRUE # optional, will add an hashtag to tweets
    restart: unless-stopped
```

## Local

- Firefox installed
- You will need these dependencies:

  ```sh
  $ opam install cohttp-lwt-unix dotenv twostep lwt_ssl yojson core
  ```

- Populate your credentials in [config/.env](./config/.env)
- Then you can run the bot with:

  ```sh
  $ dune exec pusk
  ```

## Name history

Derived from Elon's name :D. Thanks, Elon, for destroying Twitter.
