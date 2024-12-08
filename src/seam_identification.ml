open Types
open Core


let calc_minimal_energy_to_bottom (energy_map: energy_map) : Minimal_energy_map.t =
  let initial_map = Minimal_energy_map.from_energy_map energy_map in
  Minimal_energy_map.iteri_bottom_to_top initial_map ~f:(fun row col pair ->
    let current_energy = Pair.get_energy pair in
    if row = 0 then pair (* Top row remains unchanged *)
    else
      let neighbors = Array_2d.bottom_neighbors ~arr:initial_map ~row:(row - 1) ~col in
      let min_neighbor_energy, min_dir =
        List.foldi neighbors ~init:(Float.infinity, 0)
          ~f:(fun i (min_energy, min_direction) neighbor ->
            let dir = match i with
              | 0 -> -1  (* SW *)
              | 1 -> 0   (* S *)
              | 2 -> 1   (* SE *)
              | _ -> failwith "Unexpected neighbor count"
            in
            let neighbor_energy = Pair.get_energy neighbor in
            if Float.compare neighbor_energy min_energy < 0 then (neighbor_energy, dir)
            else (min_energy, min_direction))
      in
      Pair.create ~in_energy:(current_energy +. min_neighbor_energy) ~in_direction:min_dir
  )

  let find_vertical_seam (minimal_energy_map: Minimal_energy_map.t) : int array =
    let rows, _cols = Array_2d.dimensions minimal_energy_map in
  
    let start_col = Minimal_energy_map.get_minimal_energy minimal_energy_map 0 in
  
    let rec trace_seam row col acc =
      if row >= rows then Array.of_list (List.rev acc)
      else
        match Array_2d.get ~arr:minimal_energy_map ~row ~col with
        | None -> failwith "Invalid access during seam tracing"
        | Some current_pair ->
          let next_col = col + Pair.get_direction current_pair in
          trace_seam (row + 1) next_col (col :: acc)
    in
    trace_seam 0 start_col []
  

  let remove_vertical_seam (_image: image) (_seam: int array) : image =
    let height, width = Array_2d.dimensions _image in
    let new_width = width - 1 in
    Array_2d.init ~rows:height ~cols:new_width (fun y x ->
      if x < _seam.(y) then
        _image.(y).(x)
      else
        _image.(y).(x + 1)
    )
