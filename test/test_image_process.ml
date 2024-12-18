open OUnit2
open Core
open Types
open Image_process

let test_calculate_energy_map _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20}; {r=30; g=30; b=30} |];
    [| {r=40; g=40; b=40}; {r=50; g=50; b=50}; {r=60; g=60; b=60} |];
    [| {r=70; g=70; b=70}; {r=80; g=80; b=80}; {r=90; g=90; b=90} |]
  |] in
  let energy_map = ImageProcess.calculate_energy_map ~object_removal:false None img in
  assert_equal ~msg:"Energy map dimensions failed" (Array_2d.dimensions energy_map) (3, 3);
  assert_bool "Energy map non-zero test failed" (Float.compare energy_map.(1).(1) 0.0 > 0)

let test_draw_seam _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20}; {r=30; g=30; b=30} |];
    [| {r=40; g=40; b=40}; {r=50; g=50; b=50}; {r=60; g=60; b=60} |];
  |] in
  let seam = [|1; 1|] in
  let img_with_seam = ImageProcess.draw_seam img seam in
  assert_equal ~msg:"Seam not drawn correctly (row 0)" img_with_seam.(0).(1) {r=255; g=105; b=180};
  assert_equal ~msg:"Seam not drawn correctly (row 1)" img_with_seam.(1).(1) {r=255; g=105; b=180}

let test_pad_image_with_black _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20} |];
    [| {r=30; g=30; b=30}; {r=40; g=40; b=40} |]
  |] in
  let padded_img = ImageProcess.pad_image_with_black img ~target_rows:3 ~target_cols:4 in
  assert_equal ~msg:"Padding dimensions failed" (Array_2d.dimensions padded_img) (3, 4);
  assert_equal ~msg:"Padding pixel incorrect" padded_img.(2).(2) {r=0; g=0; b=0}

let test_perform_seam_removal _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20}; {r=30; g=30; b=30} |];
    [| {r=40; g=40; b=40}; {r=50; g=50; b=50}; {r=60; g=60; b=60} |];
  |] in
  let results = ImageProcess.perform_seam_removal img 1 2 3 in
  assert_equal ~msg:"Seam removal image count failed" (List.length results) 2;
  assert_equal ~msg:"Seam dimensions incorrect" (Array_2d.dimensions (Option.value_exn (List.nth results 1))) (2, 3)

let test_remove_seams _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20} |];
    [| {r=30; g=30; b=30}; {r=40; g=40; b=40} |]
  |] in
  let results = ImageProcess.remove_seams img 1 Orientation.Vertical in
  assert_equal ~msg:"Image list count incorrect" (List.length results) 2;
  assert_equal ~msg:"Seam dimensions incorrect" (Array_2d.dimensions (Option.value_exn (List.nth results 1))) (2, 2)

let test_remove_object _ =
  let img = [|
    [| {r=10; g=10; b=10}; {r=20; g=20; b=20} |];
    [| {r=30; g=30; b=30}; {r=40; g=40; b=40} |]
  |] in
  let mask = [ (0, 1); (1, 1) ] in
  let seams, images = ImageProcess.remove_object img mask [] in
  assert_equal ~msg:"Seam list length incorrect" (List.length seams) 2;
  assert_equal ~msg:"Image list length incorrect" (List.length images) 4;
  assert_equal ~msg:"Padded image dimensions incorrect" (Array_2d.dimensions (Option.value_exn (List.nth images 1))) (2, 2);

  (* Test with empty mask *)
  let empty_mask = [] in
  let seams, images = ImageProcess.remove_object img empty_mask [] in
  assert_equal ~msg:"Empty mask returns a seam" seams [];
  assert_equal ~msg:"Empty mask incorrectly returns an image" images []

let suite =
  "Image Process Tests" >::: [
    "test_calculate_energy_map" >:: test_calculate_energy_map;
    "test_draw_seam" >:: test_draw_seam;
    "test_pad_image_with_black" >:: test_pad_image_with_black;
    "test_perform_seam_removal" >:: test_perform_seam_removal;
    "test_remove_seams" >:: test_remove_seams;
    "test_remove_object" >:: test_remove_object;
  ]

let () = run_test_tt_main suite

