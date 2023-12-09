(lang dune 3.11)

(name search_engine)

(maintainers "henri <henri@henr.in>")

(authors "henri <henri@henr.in>")

(version 3659bfa-dirty)

(generate_opam_files true)

(source
 (github hnrbs/search-engine))

(license LICENSE)

(documentation https://github.com/hnrbs/search-engine)

(package
 (name search_engine)
 (synopsis "Simple crawler and search engine")
 (description "Search engine written entirely in OCaml.")
 (depends 
  ocaml
  dune
  lambdasoup
  ppx_deriving
  piaf
  cohttp-lwt-unix
  lwt
  sqlite3)

 (tags (topics "to describe" your project)))
