# syntax=docker/dockerfile:1

FROM ocaml/opam:alpine-3.22-ocaml-5.5 AS builder
WORKDIR /usr/src/pusk
COPY . .

USER root
RUN apk add gmp-dev pcre-dev openssl-dev && \
  chown -R opam:opam .

USER opam
RUN opam install -y dune cohttp-lwt-unix dotenv twostep lwt_ssl yojson core && \
  eval $(opam env) && \
  dune build --profile=release


FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache \
  dumb-init firefox libc6-compat pcre-dev

COPY --from=builder /usr/src/pusk/_build/default/bin/main.exe /app/pusk
COPY --from=builder /usr/src/pusk/LICENSE /app/LICENSE

CMD ["dumb-init", "/app/pusk"]
