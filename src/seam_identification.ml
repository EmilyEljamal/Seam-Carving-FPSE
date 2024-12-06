open Types
(* open Core *)

  let calc_minimal_energy_to_bottom (_energy_map: energy_map) : Minimal_energy_map.t =
    let minimal_map_init = Minimal_energy_map.from_energy_map _energy_map in
    let minimal_energy_map = Minimal_energy_map.iteri_bottom_to_top minimal_map_init ~f:(fun row col pair ->
      let current_energy = Pair.get_energy pair in
      if row = 0 then
        pair
      else
        let neighbors = Array_2d.bottom_neighbors ~arr:minimal_map_init ~row:(row-1) ~col in
        let candidates =
          List.mapi (fun i nbr ->
            let dir = match i with
              | 0 -> -1  (* SW *)
              | 1 -> 0   (* S *)
              | 2 -> 1   (* SE *)
              | _ -> failwith "Unexpected neighbor count"
            in
            (Pair.get_energy nbr, dir)
          ) neighbors  in 
        let (min_neighbor_energy, min_dir) =
        List.fold_left (fun (best_e, best_d) (e, d) ->
          if Float.compare e best_e < 0 then (e, d) else (best_e, best_d)
        ) (Float.infinity, 0) candidates
        
        
        in
        Pair.create ~in_energy:(current_energy +. min_neighbor_energy) ~in_direction:min_dir
    ) in
    minimal_energy_map
  
  

let find_vertical_seam (_minimal_energy_map: Minimal_energy_map.t) : int array =
  failwith "Not implemented yet"
  (* pick the top row value with the min value *)
  (* use the direction to build the int list from there *)

let remove_vertical_seam (_image: image) (_seam: int array) : image =
  failwith "Not implemented yet"
