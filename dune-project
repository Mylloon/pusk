(lang dune 3.13)

(name pusk)

(generate_opam_files true)

(source
 (uri https://git.mylloon.fr/Anri/pusk.git))

(authors "Mylloon")

(maintainers "Mylloon")

(license AGPL-3.0-or-later)

(package
 (name pusk)
 (synopsis "Twitter bot")
 (description "Send tweet peridically to avoid ban from Elon")
 (depends
  ocaml
  dune
  (cohttp-lwt-unix
   (>= 5.3))
  (dotenv
   (>= 0.0))
  (twostep
   (>= 1.0)))
 (tags
  (api twitter)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
