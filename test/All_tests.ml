open OUnit2

let suite =
  "All Tests" >::: [
    Test_types.suite;
    Test_seam_carving.suite;
    Test_image_process.suite;
  ]

let () =
  run_test_tt_main suite
