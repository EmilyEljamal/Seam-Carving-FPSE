(lang dune 3.16)
(generate_opam_files true)

(authors "Maria-Noelia Herne Emily Eljamal")

(maintainers "FPSEfall2024@example.com")

(package
 (name seam_carving)
 (allow_empty)
 (synopsis "An OCaml library for seam carving and image processing.")
 (description
  "An OCaml library for advanced image manipulation and seam carving techniques.")
 (depends
  (ounit2 (>= 2.2.7)) ; for each opam dependency list the version
  (core (>= 0.17.1)) ; `opam list core` will display which version of core you have
))
