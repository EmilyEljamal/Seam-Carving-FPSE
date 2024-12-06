open Types

let calc_minimal_energy_to_bottom (_energy_map: energy_map) : Minimal_energy_map.t =
  failwith "Not implemented yet"
  (* let minimal_map_init = Minimal_energy_map.from_energy_map _energy_map *)
  (* copy the bottom row using Array.copy *)
  (* bottom to top, left to right  using Array rev*)
  (* for each cell check adding cell value to each bottom neighbor *)
  (* save the min value of the 3 and its corresponding direction into a new map*)

let find_vertical_seam (_minimal_energy_map: Minimal_energy_map.t) : int array =
  failwith "Not implemented yet"
  (* pick the top row value with the min value *)
  (* use the direction to build the int list from there *)

let remove_vertical_seam (_image: image) (_seam: int array) : image =
  failwith "Not implemented yet"
