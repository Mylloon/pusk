# syntax=docker/dockerfile:1

FROM ocaml/opam:alpine-3.17-ocaml-4.14 AS builder
WORKDIR /usr/src/pusk
COPY . .

USER root
RUN apk add gmp-dev pcre-dev && \
  chown -R opam:opam .

USER opam
RUN opam install -y dune cohttp-lwt-unix dotenv twostep lwt_ssl && \
  eval $(opam env) && \
  dune install

FROM alpine:3.17

WORKDIR /app

RUN apk add dumb-init firefox libc6-compat pcre-dev

COPY --from=builder /usr/src/pusk/_build/install/default/bin/pusk /app/pusk

CMD ["dumb-init", "./pusk"]
