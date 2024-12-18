open OUnit2
open Core
open Types
open Direction

  let test_calc_minimal_energy_to_bottom _ =
    let energy_map = [|
      [| 10.0; 20.0; 30.0 |];
      [| 5.0; 15.0; 25.0 |];
      [| 1.0; 1.0; 1.0 |];
    |] in
    let create_pair energy direction =
      Pair.create ~in_energy:energy ~in_direction:direction
    in
    let expected_map = [|
      [| create_pair 1.0 Neutral;   create_pair 1.0 Neutral;    create_pair 1.0 Neutral   |];
      [| create_pair 6.0 South;     create_pair 16.0 SouthWest; create_pair 26.0 SouthWest |];
      [| create_pair 16.0 South;    create_pair 26.0 SouthWest; create_pair 46.0 SouthWest |];
    |] in
    let result_map = Seam_identification.calc_minimal_energy_to_bottom energy_map in
    Array.iteri result_map ~f:(fun row result_row ->
      Array.iteri result_row ~f:(fun col result_pair ->
        let expected_pair = expected_map.(row).(col) in
        assert_equal (Pair.get_energy result_pair) (Pair.get_energy expected_pair)
          ~msg:(Printf.sprintf "Energy mismatch at (%d, %d)" row col);
        assert_equal (Pair.get_direction result_pair) (Pair.get_direction expected_pair)
          ~msg:(Printf.sprintf "Direction mismatch at (%d, %d)" row col)
      )
    )

let test_find_vertical_seam _ =
    let create_pair energy direction =
      Pair.create ~in_energy:energy ~in_direction:direction
    in
    let minimal_energy_map = [|
      [| create_pair 1.0 East;    create_pair 2.0 Neutral;   create_pair 3.0 East  |];
      [| create_pair 6.0 South;    create_pair 16.0 East;    create_pair 26.0 Neutral |];
      [| create_pair 16.0 East; create_pair 26.0 Neutral; create_pair 46.0 Neutral |];
    |] in
    let seam = Seam_identification.find_vertical_seam minimal_energy_map in
    assert_equal seam [|0; 1; 2|] ~msg:"Seam finding failed for minimal energy map"

  let test_remove_vertical_seam _ =
    let image = Array_2d.init ~rows:3 ~cols:3 (fun i j ->
      match i with
      | 0 -> if j = 0 then { r = 255; g = 0; b = 0 } else if j = 1 then { r = 0; g = 255; b = 0 } else { r = 0; g = 0; b = 255 }
      | 1 -> if j = 0 then { r = 128; g = 128; b = 128 } else if j = 1 then { r = 64; g = 64; b = 64 } else { r = 32; g = 32; b = 32 }
      | 2 -> if j = 0 then { r = 10; g = 10; b = 10 } else if j = 1 then { r = 20; g = 20; b = 20 } else { r = 30; g = 30; b = 30 }
      | _ -> { r = 0; g = 0; b = 0 }
    ) in
    let seam = [|1; 1; 1|] in
    let new_image = Seam_identification.remove_vertical_seam image seam in
    assert_equal (Array_2d.dimensions new_image) (3, 2) ~msg:"Basic seam removal failed";
    assert_equal 
      (Array_2d.get ~arr:new_image ~row:0 ~col:1) 
      (Some { r = 0; g = 0; b = 255 }) 
      ~msg:"Seam removal did not shift correctly"

let suite =
  "All Tests" >::: [
    "Test Find Vertical Seam" >:: test_find_vertical_seam;
    "Test Remove Vertical Seam" >:: test_remove_vertical_seam;
    "Test Calc Minimal Energy To Bottom" >:: test_calc_minimal_energy_to_bottom;
  ]

let () =
  run_test_tt_main suite
