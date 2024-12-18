(* open OUnit2
open Core
open Types


let test_pair _ =
  let pair = Pair.create ~in_energy:10.5 ~in_direction:1 in
  assert_equal (Pair.get_energy pair) 10.5 ~msg:"Energy retrieval failed";
  assert_equal (Pair.get_direction pair) 1 ~msg:"Direction retrieval failed";
  let updated_pair = Pair.update_energy pair 15.0 in
  assert_equal (Pair.get_energy updated_pair) 15.0 ~msg:"Energy update failed";
  assert_equal (Pair.get_direction updated_pair) 1 ~msg:"Direction should remain the same"

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

let test_minimal_energy_map _ =
  let energy_map = Array_2d.init ~rows:3 ~cols:3 (fun _ _ -> 5.0) in
  let min_energy_map = Minimal_energy_map.from_energy_map energy_map in
  assert_equal (Minimal_energy_map.get_minimal_energy min_energy_map 0) 0 ~msg:"Minimal energy retrieval failed";
  assert_raises (Failure "Invalid row index") (fun () ->
    Minimal_energy_map.get_minimal_energy min_energy_map 4
  ) ~msg:"Invalid row index failed for get minimal energy";
  (* assert_equal (Minimal_energy_map.to_energy_map min_energy_map) energy_map ~msg:"To energy map failed"; *)
  Minimal_energy_map.update_direction min_energy_map 0 0 1;
  match Array_2d.get ~arr:min_energy_map ~row:0 ~col:0 with
  | None -> assert_failure "Pair not found in energy map"
  | Some pair -> assert_equal (Pair.get_direction pair) 1 ~msg:"Direction update failed";
  assert_raises (Failure "Invalid row index") (fun () ->
    Minimal_energy_map.update_direction min_energy_map 4 4 10
  ) ~msg:"Invalid row index failed for update direction"

let test_find_vertical_seam _ =
  let minimal_energy_map = Minimal_energy_map.from_energy_map [|
    [|10.0; 20.0; 30.0|];
    [|15.0; 5.0; 25.0|];
    [|40.0; 10.0; 5.0|];
  |] in
  let seam = Seam_identification.find_vertical_seam minimal_energy_map in
  assert_equal seam [|2; 1; 0|] ~msg:"Basic seam finding failed";

  let minimal_energy_map2 = Minimal_energy_map.from_energy_map [|
    [|10.0; 20.0; 30.0; 40.0|];
    [|15.0; 5.0; 25.0; 35.0|];
    [|40.0; 10.0; 5.0; 25.0|];
  |] in
  let seam2 = Seam_identification.find_vertical_seam minimal_energy_map2 in
  assert_equal seam2 [|1; 1; 1|] ~msg:"Handling non-trivial seam failed";

  let minimal_energy_map3 = Minimal_energy_map.from_energy_map [|
    [|1.0; 1.0; 1.0|];
    [|1.0; 1.0; 1.0|];
  |] in
  let seam3 = Seam_identification.find_vertical_seam minimal_energy_map3 in
  assert_equal seam3 [|0; 0|] ~msg:"Handling edge cases seam failed";

  let minimal_energy_map4 = Minimal_energy_map.from_energy_map [|
    [|100.0; 200.0; 300.0; 400.0; 500.0|];
    [|150.0; 50.0; 250.0; 350.0; 450.0|];
    [|200.0; 100.0; 50.0; 150.0; 250.0|];
    [|400.0; 300.0; 200.0; 100.0; 50.0|];
  |] in
  let seam4 = Seam_identification.find_vertical_seam minimal_energy_map4 in
  assert_equal seam4 [|1; 1; 1; 1|] ~msg:"Large image seam failed";

  assert_raises (Failure "Invalid row index") (fun () ->
    Seam_identification.find_vertical_seam minimal_energy_map3) ~msg:"Invalid row index failed";

  let minimal_energy_map_edge = Minimal_energy_map.from_energy_map [|[|5.0|]|] in 
  let seam_edge = Seam_identification.find_vertical_seam minimal_energy_map_edge in
  assert_equal seam_edge [|0|] ~msg:"1x1 image seam failed"


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
  ~msg:"Seam removal did not shift correctly";

let seam_edge = [|0; 0; 0|] in
let new_image_edge = Seam_identification.remove_vertical_seam image seam_edge in
assert_equal (Array_2d.dimensions new_image_edge) (3, 2) ~msg:"Seam removal at edges failed";
assert_equal 
  (Array_2d.get ~arr:new_image_edge ~row:0 ~col:0) 
  (Some { r = 0; g = 255; b = 0 }) 
  ~msg:"Seam removal at left edge failed";

let image_min = Array_2d.init ~rows:1 ~cols:1 (fun _ _ -> { r = 1; g = 1; b = 1 }) in
let seam_min = [|0|] in
let new_image_min = Seam_identification.remove_vertical_seam image_min seam_min in
assert_equal (Array_2d.dimensions new_image_min) (1, 0) ~msg:"Removing seam in minimum size image failed";

let seam_invalid = [|2; 3; 4|] in
assert_raises (Invalid_argument "Array2d out of bounds") (fun () ->
  Seam_identification.remove_vertical_seam image seam_invalid) ~msg:"Handling out-of-bounds seam indices failed";

(* Edge case: 1x1 image *)
let image_edge = Array_2d.init ~rows:1 ~cols:1 (fun _ _ -> { r = 5; g = 5; b = 5 }) in
  let seam_edge_single = [|0|] in
  let new_image_edge_single = Seam_identification.remove_vertical_seam image_edge seam_edge_single in
  assert_equal (Array_2d.dimensions new_image_edge_single) (1, 0) ~msg:"Seam removal from 1x1 image failed"

  let test_calc_minimal_energy_to_bottom _ =
    let energy_map = Array_2d.init ~rows:3 ~cols:3 (fun row col ->
      match (row, col) with
      | (0, 0) -> 10.0
      | (0, 1) -> 20.0
      | (0, 2) -> 30.0
      | (1, 0) -> 5.0
      | (1, 1) -> 15.0
      | (1, 2) -> 25.0
      | (2, 0) -> 1.0
      | (2, 1) -> 1.0
      | (2, 2) -> 1.0
      | _ -> failwith "Out of bounds"
    ) in
  
    let minimal_energy_map = Seam_identification.calc_minimal_energy_to_bottom energy_map in

    let print_minimal_energy_map (map: Minimal_energy_map.t) =
      let rows, cols = Array_2d.dimensions map in
      for row = 0 to rows - 1 do
        for col = 0 to cols - 1 do
          let pair = Array_2d.get ~arr:map ~row ~col |> Option.value_exn in
          let energy = Pair.get_energy pair in
          let direction = Pair.get_direction pair in
          Printf.printf "(%d, %d) -> Energy: %.2f, Direction: %d\n" row col energy direction
        done;
        Stdlib.print_newline ()
      done in
    
    print_minimal_energy_map minimal_energy_map;
  
    let get_pair arr row col =
      match Array_2d.get ~arr ~row ~col with
      | Some value -> value
      | None -> failwith (Printf.sprintf "Out of bounds: row=%d, col=%d" row col)
    in
  
    (* Step 3: Assert the results for the minimal energy map *)
    (* Row 2: Bottom row should equal the energy map directly *)
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 2 0)) 1.0 ~msg:"Row 2, Col 0";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 2 1)) 1.0 ~msg:"Row 2, Col 1";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 2 2)) 1.0 ~msg:"Row 2, Col 2";
  
    (* Row 1: Sum with minimal neighbor from row 2 *)
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 1 0)) 6.0 ~msg:"Row 1, Col 0";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 1 1)) 16.0 ~msg:"Row 1, Col 1";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 1 2)) 26.0 ~msg:"Row 1, Col 2";
  
    (* Row 0: Sum with minimal neighbor from row 1 *)
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 0 0)) 16.0 ~msg:"Row 0, Col 0";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 0 1)) 26.0 ~msg:"Row 0, Col 1";
    assert_equal (Pair.get_energy (get_pair minimal_energy_map 0 2)) 46.0 ~msg:"Row 0, Col 2";
  
    (* Debugging complete map to ensure all values match *)
    Printf.printf "Debugging completed, assertions passed.\n"

(* Test suite *)
let suite =
  "All Tests" >::: [
    (* "Test Pair module" >:: test_pair;
    "Test Array_2d module" >:: test_array_2d;
    "Test Minimal_energy_map module" >:: test_minimal_energy_map;
    "Test Vertical Seam" >:: test_find_vertical_seam;
    "Test Remove Seam" >:: test_remove_vertical_seam;
      "test_calc_minimal_energy_to_bottom" >:: test_calc_minimal_energy_to_bottom
  ]

let () =
  run_test_tt_main suite *)
