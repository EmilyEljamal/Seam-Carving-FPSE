open OUnit2
open Core
open Types

(* Test for Pair module *)
let test_pair _ =
  let pair = Pair.create ~in_energy:10.5 ~in_direction:1 in
  assert_equal (Pair.get_energy pair) 10.5 ~msg:"Energy retrieval failed";
  assert_equal (Pair.get_direction pair) 1 ~msg:"Direction retrieval failed";
  let updated_pair = Pair.update_energy pair 15.0 in
  assert_equal (Pair.get_energy updated_pair) 15.0 ~msg:"Energy update failed";
  assert_equal (Pair.get_direction updated_pair) 1 ~msg:"Direction should remain the same"

(* Test for Array_2d module *)
let test_array_2d _ =
  let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row + col) in
  let expected_row = Some [| 2; 3; 4; |] in
  assert_equal (Array_2d.get ~arr ~row:0 ~col:0) (Some 0) ~msg:"Initialization failed";
  assert_equal (Array_2d.get ~arr ~row:1 ~col:1) (Some 2) ~msg:"Initialization failed";
  assert_equal (Array_2d.get ~arr ~row:5 ~col:5) None ~msg:"Out-of-bounds check failed";
  assert_equal (Array_2d.get_row arr 2) expected_row ~msg:"Get row failed";
  assert_equal (Array_2d.get_row arr 4) None ~msg:"Out of bounds get row failed";
  assert_equal (Array_2d.dimensions arr) (3,3) ~msg:"Dimensions failed";
  let adj = Array_2d.adjacents ~arr ~row:1 ~col:1 in
  assert_equal adj [1; 3; 1; 3] ~msg:"Adjacents calculation failed"

(* Test for Minimal_energy_map module *)
let test_minimal_energy_map _ =
  let energy_map = Array_2d.init ~rows:3 ~cols:3 (fun _ _ -> 5.0) in
  let min_energy_map = Minimal_energy_map.from_energy_map energy_map in
  assert_equal (Minimal_energy_map.get_minimal_energy min_energy_map 0) 0 ~msg:"Minimal energy retrieval failed";
  assert_equal (Minimal_energy_map.to_energy_map min_energy_map) energy_map ~msg:"To energy map failed";
  Minimal_energy_map.update_direction min_energy_map 0 0 1;
  match Array_2d.get ~arr:min_energy_map ~row:0 ~col:0 with
  | Some pair -> assert_equal (Pair.get_direction pair) 1 ~msg:"Direction update failed"
  | None -> assert_failure "Pair not found in energy map"
  
(* Test suite *)
let suite =
  "All Tests" >::: [
    "Test Pair module" >:: test_pair;
    "Test Array_2d module" >:: test_array_2d;
    "Test Minimal_energy_map module" >:: test_minimal_energy_map;
  ]

let () =
  run_test_tt_main suite
