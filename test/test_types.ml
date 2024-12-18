open OUnit2
open Core
open Types
open Direction


  let test_direction_module _ =
  (* Test offsets *)
  assert_equal (direction_to_offset NorthWest) (-1, -1) ~msg:"NorthWest offset failed";
  assert_equal (direction_to_offset NorthEast) (-1, 1) ~msg:"NorthEast offset failed";
  assert_equal (direction_to_offset SouthWest) (1, -1) ~msg:"SouthWest offset failed";
  assert_equal (direction_to_offset SouthEast) (1, 1) ~msg:"SouthEast offset failed";

  (* Test horizontal offsets *)
  assert_equal (horizontal_offset NorthWest) (-1) ~msg:"NorthWest horizontal offset failed";
  assert_equal (horizontal_offset NorthEast) 1 ~msg:"NorthEast horizontal offset failed";
  assert_equal (horizontal_offset SouthWest) (-1) ~msg:"SouthWest horizontal offset failed";
  assert_equal (horizontal_offset SouthEast) 1 ~msg:"SouthEast horizontal offset failed";

  (* Test next column calculations *)
  assert_equal (next_col ~col:5 ~direction:NorthWest) 4 ~msg:"Next column for NorthWest failed";
  assert_equal (next_col ~col:5 ~direction:NorthEast) 6 ~msg:"Next column for NorthEast failed";
  assert_equal (next_col ~col:5 ~direction:SouthWest) 4 ~msg:"Next column for SouthWest failed";
  assert_equal (next_col ~col:5 ~direction:SouthEast) 6 ~msg:"Next column for SouthEast failed"

  let test_energy_module _ =
  let neighbors = [
    (West, { r = 10; g = 10; b = 10 });
    (East, { r = 20; g = 20; b = 20 });
    (North, { r = 30; g = 30; b = 30 });
    (South, { r = 40; g = 40; b = 40 })
  ] in
  let energy = Energy.calculate_pixel_energy ~neighbors in
  assert_equal energy 600.0 ~msg:"Energy calculation failed"

  let test_pair_module _ =
  let pair = Pair.create ~in_energy:10.5 ~in_direction:South in
  assert_equal (Pair.get_energy pair) 10.5 ~msg:"Energy retrieval failed";
  assert_equal (Pair.get_direction pair) South ~msg:"Direction retrieval failed";
  let updated_pair = Pair.update_energy pair 15.0 in
  assert_equal (Pair.get_energy updated_pair) 15.0 ~msg:"Energy update failed";
  assert_equal (Pair.get_direction updated_pair) South ~msg:"Direction should remain the same"

  let test_array_2d_init _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row + col) in
    assert_equal (Array_2d.get ~arr ~row:0 ~col:0) (Some 0) ~msg:"Initialization failed at (0, 0)";
    assert_equal (Array_2d.get ~arr ~row:1 ~col:2) (Some 3) ~msg:"Initialization failed at (1, 2)";
    assert_equal (Array_2d.dimensions arr) (3, 3) ~msg:"Dimensions check failed";
    assert_equal (Array_2d.get ~arr ~row:5 ~col:5) None ~msg:"Out-of-bounds check failed"

  let test_array_2d_get_row _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row * 3 + col) in
    assert_equal (Array_2d.get_row arr 1) (Some [|3; 4; 5|]) ~msg:"Row retrieval failed for row 1";
    assert_equal (Array_2d.get_row arr 5) None ~msg:"Out-of-bounds row retrieval failed"

  let test_array_2d_set _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row + col) in
    Array_2d.set ~arr ~row:1 ~col:1 42;
    assert_equal (Array_2d.get ~arr ~row:1 ~col:1) (Some 42) ~msg:"Set operation failed"

  let test_array_2d_map _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row + col) in
    let mapped_arr = Array_2d.map (fun _ _ value -> value * 2) arr in
    assert_equal (Array_2d.get ~arr:mapped_arr ~row:1 ~col:1) (Some 4) ~msg:"Mapping failed at (1, 1)";
    assert_equal (Array_2d.get ~arr:mapped_arr ~row:2 ~col:2) (Some 8) ~msg:"Mapping failed at (2, 2)"

  let test_array_2d_copy _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row + col) in
    let copied_arr = Array_2d.copy arr in
    Array_2d.set ~arr:copied_arr ~row:0 ~col:0 99;
    assert_equal (Array_2d.get ~arr:arr ~row:0 ~col:0) (Some 0) ~msg:"Original array should remain unchanged after copy"

  let test_array_2d_neighbors _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row * 3 + col) in
    let neighbors = Array_2d.neighbors ~arr ~row:1 ~col:1 ~directions:[North; South; East; West] in
    assert_equal neighbors [
      (North, 1); (South, 7); (East, 5); (West, 3)
    ] ~msg:"Neighbor calculation failed"

  let test_array_2d_bottom_neighbors _ =
    let arr = Array_2d.init ~rows:3 ~cols:3 (fun row col -> row * 3 + col) in
    let bottom_neighbors = Array_2d.bottom_neighbors ~arr ~row:1 ~col:1 in
    assert_equal bottom_neighbors [
      (SouthWest, 6); (South, 7); (SouthEast, 8)
    ] ~msg:"Bottom neighbor calculation failed"

  let test_array_2d_transpose _ =
    let arr = Array_2d.init ~rows:2 ~cols:3 (fun row col -> row * 3 + col) in
    let transposed_arr = Array_2d.transpose arr in
    assert_equal (Array_2d.dimensions transposed_arr) (3, 2) ~msg:"Transpose dimensions failed";
    assert_equal (Array_2d.get ~arr:transposed_arr ~row:0 ~col:1) (Some 3) ~msg:"Transpose content failed at (0, 1)";
    assert_equal (Array_2d.get ~arr:transposed_arr ~row:2 ~col:1) (Some 5) ~msg:"Transpose content failed at (2, 1)"

  let test_minimal_energy_map_module _ =
    let energy_map = Array_2d.init ~rows:3 ~cols:3 (fun _ _ -> 5.0) in
    let min_energy_map = Minimal_energy_map.from_energy_map energy_map in
    assert_equal (Minimal_energy_map.get_minimal_energy min_energy_map 0) 0 ~msg:"Minimal energy retrieval failed";
    assert_raises (Failure "Invalid row index") (fun () ->
      Minimal_energy_map.get_minimal_energy min_energy_map 4
    ) ~msg:"Invalid row index failed for get minimal energy";
    Minimal_energy_map.update_direction min_energy_map 0 0 South;
    match Array_2d.get ~arr:min_energy_map ~row:0 ~col:0 with
    | None -> assert_failure "Pair not found in energy map"
    | Some pair -> assert_equal (Pair.get_direction pair) South ~msg:"Direction update failed";
    assert_raises (Failure "Invalid row index") (fun () ->
      Minimal_energy_map.update_direction min_energy_map 4 4 East
    ) ~msg:"Invalid row index failed for update direction"

  let test_map_bottom_to_top _ =
    let original_map = [|
      [| Pair.create ~in_energy:1.0 ~in_direction:Neutral; Pair.create ~in_energy:2.0 ~in_direction:Neutral |];
      [| Pair.create ~in_energy:3.0 ~in_direction:Neutral; Pair.create ~in_energy:4.0 ~in_direction:Neutral |];
    |] in
    let transform row col pair =
      Pair.create ~in_energy:(Pair.get_energy pair +. float_of_int (row + col)) ~in_direction:South
    in
    let transformed_map = Minimal_energy_map.map_bottom_to_top original_map ~f:transform in
    let expected_map = [|
        [| Pair.create ~in_energy:4.0 ~in_direction:South; Pair.create ~in_energy:6.0 ~in_direction:South |];
        [| Pair.create ~in_energy:1.0 ~in_direction:South; Pair.create ~in_energy:3.0 ~in_direction:South |];
      |] in
    Array.iteri transformed_map ~f:(fun row arr ->
      Array.iteri arr ~f:(fun col pair ->
        let expected_pair = expected_map.(row).(col) in
        assert_equal (Pair.get_energy pair) (Pair.get_energy expected_pair) ~msg:"Energy mismatch";
        assert_equal (Pair.get_direction pair) (Pair.get_direction expected_pair) ~msg:"Direction mismatch"
      )
    )
  let test_to_energy_map _ =
    let minimal_energy_map = [|
      [| Pair.create ~in_energy:1.0 ~in_direction:Neutral; Pair.create ~in_energy:2.0 ~in_direction:South |];
      [| Pair.create ~in_energy:3.0 ~in_direction:East; Pair.create ~in_energy:4.0 ~in_direction:West |];
    |] in
    let expected_energy_map = [|
      [| 1.0; 2.0 |];
      [| 3.0; 4.0 |];
    |] in
    let actual_energy_map = Minimal_energy_map.to_energy_map minimal_energy_map in
    Array.iteri actual_energy_map ~f:(fun row arr ->
      Array.iteri arr ~f:(fun col energy ->
        assert_equal energy expected_energy_map.(row).(col) ~msg:(Printf.sprintf "Energy mismatch at (%d, %d)" row col)
      )
    )
  

let suite =
  "Types Module Tests" >::: [
    "Test Direction Module" >:: test_direction_module;
    "Test Energy Module" >:: test_energy_module;
    "Test Pair Module" >:: test_pair_module;
    "Test Array_2d Init" >:: test_array_2d_init;
    "Test Array_2d Get Row" >:: test_array_2d_get_row;
    "Test Array_2d Set" >:: test_array_2d_set;
    "Test Array_2d Map" >:: test_array_2d_map;
    "Test Array_2d Copy" >:: test_array_2d_copy;
    "Test Array_2d Neighbors" >:: test_array_2d_neighbors;
    "Test Array_2d Bottom Neighbors" >:: test_array_2d_bottom_neighbors;
    "Test Array_2d Transpose" >:: test_array_2d_transpose;
    "Test Minimal_energy_map Module" >:: test_minimal_energy_map_module;
    "Test Minimal_energy_map map_bottom_to_top" >:: test_map_bottom_to_top;
    "Test To Energy Map" >:: test_to_energy_map;
  ]

let () = 
  run_test_tt_main suite


