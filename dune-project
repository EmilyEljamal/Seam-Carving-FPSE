(lang dune 3.16)

(generate_opam_files true)

(authors "Maria-Noelia Herne Emily Eljamal")

(maintainers "maintainer@example.com")

(package
 (name seam_carving) ; updated with your project name
 (allow_empty)
 (synopsis "An OCaml library for seam carving and image processing.")
 (description
  "An OCaml library for advanced image manipulation and seam carving techniques.")
 (depends
  (ocaml
   (>= 4.12.0)) ; specify the minimum OCaml version your project supports
  (dune
   (>= 3.0))
  (core
   (>= 0.17.1)) ; include dependencies as needed
  (ounit2
   (>= 2.2.7)) ; example dependency for testing
               ; Add any external opam packages here
  ))
