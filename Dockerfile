# syntax=docker/dockerfile:1

FROM ocaml/opam:alpine-3.18-ocaml-4.14 AS builder
WORKDIR /usr/src/pusk
COPY . .

USER root
RUN apk update && \
  apk add gmp-dev pcre-dev openssl-dev && \
  chown -R opam:opam .

USER opam
RUN opam install -y dune cohttp-lwt-unix dotenv twostep lwt_ssl yojson core && \
  eval $(opam env) && \
  dune build --profile=release

FROM alpine:3.18

WORKDIR /app

RUN apk update && \
  apk add dumb-init firefox libc6-compat pcre-dev && \
  rm -rf /var/cache/apk/*

COPY --from=builder /usr/src/pusk/_build/default/bin/main.exe /app/pusk

CMD ["dumb-init", "./pusk"]
