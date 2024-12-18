open Types
open Core

  let calc_minimal_energy_to_bottom (energy_map: energy_map) : Minimal_energy_map.t =
    let initial_map = Minimal_energy_map.from_energy_map energy_map in
    let rows, _ = Array_2d.dimensions initial_map in
    let update_pair row col pair =
      let current_energy = Pair.get_energy pair in
      if row = rows - 1 then
        pair
      else
        let neighbors = Array_2d.bottom_neighbors ~arr:initial_map ~row ~col in
        let min_neighbor_energy, min_dir =
          List.fold ~init:(Float.infinity, Direction.Neutral)
            ~f:(fun (min_energy, min_direction) (dir, neighbor) ->
              let neighbor_energy = Pair.get_energy neighbor in
              if Float.compare neighbor_energy min_energy < 0 then (neighbor_energy, dir)
              else (min_energy, min_direction)
            )
            neighbors
        in
        Pair.create ~in_energy:(current_energy +. min_neighbor_energy) ~in_direction:min_dir
    in
    Minimal_energy_map.map_bottom_to_top initial_map ~f:(fun row col pair -> 
      let updated_pair = update_pair row col pair in 
      Array_2d.set ~arr:initial_map ~row ~col updated_pair;
      updated_pair
  )

  let find_vertical_seam (minimal_energy_map : Minimal_energy_map.t) : int array =
    let rows, _ = Array_2d.dimensions minimal_energy_map in
    let start_col = Minimal_energy_map.get_minimal_energy minimal_energy_map (rows - 1) in
    let rec trace_seam row col seam =
      if row < 0 then List.rev seam
      else
        let pair =
          Option.value (Array_2d.get ~arr:minimal_energy_map ~row ~col)
            ~default:(Pair.create ~in_energy:0.0 ~in_direction:Direction.Neutral)
        in
        let direction = Pair.get_direction pair in
        let next_col = Direction.next_col ~col ~direction in
        trace_seam (row - 1) next_col (col :: seam)
    in
    Array.of_list (trace_seam (rows - 1) start_col [])
  
  let remove_vertical_seam (image: image) (seam: int array) : image =
    let height, width = Array_2d.dimensions image in
    let new_width = width - 1 in
    Array_2d.init ~rows:height ~cols:new_width (fun y x ->
      if x < seam.(y) then
        image.(y).(x)
      else
        image.(y).(x + 1)
    )