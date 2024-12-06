open Types
(* open Core *)

let calc_minimal_energy_to_bottom (energy_map: energy_map) : Minimal_energy_map.t =
  let initial_map = Minimal_energy_map.from_energy_map energy_map in
  let update_pair row col pair =
    let current_energy = Pair.get_energy pair in
    if row = 0 then
      pair
    else
      let neighbors = Array_2d.bottom_neighbors ~arr:initial_map ~row:(row - 1) ~col in
      let min_neighbor_energy, min_dir =
        List.fold_left (fun (min_energy, min_direction) (i, neighbor) ->
          let dir = match i with
            | 0 -> -1  (* SW *)
            | 1 -> 0   (* S *)
            | 2 -> 1   (* SE *)
            | _ -> failwith "Unexpected neighbor count"
          in
          let neighbor_energy = Pair.get_energy neighbor in
          if Float.compare neighbor_energy min_energy < 0 then (neighbor_energy, dir)
          else (min_energy, min_direction)
        ) (Float.infinity, 0) (List.mapi (fun i nbr -> (i, nbr)) neighbors)
      in
      Pair.create ~in_energy:(current_energy +. min_neighbor_energy) ~in_direction:min_dir
  in
  Minimal_energy_map.iteri_bottom_to_top initial_map ~f:update_pair
  
let find_vertical_seam (_minimal_energy_map: Minimal_energy_map.t) : int array =
  failwith "Not implemented yet"
  (* pick the top row value with the min value *)
  (* use the direction to build the int list from there *)

let remove_vertical_seam (_image: image) (_seam: int array) : image =
  failwith "Not implemented yet"
