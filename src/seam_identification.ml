open Types
open Core

let calc_minimal_energy_to_bottom (energy_map : energy_map) : Minimal_energy_map.t =
  let minimal_energy_map = Minimal_energy_map.from_energy_map energy_map in
  let rows, cols = Array_2d.dimensions minimal_energy_map in

  for col = 0 to cols - 1 do
    let energy = energy_map.(0).(col) in
    minimal_energy_map.(0).(col) <- Pair.create ~in_energy:energy ~in_direction:0
  done;

  for row = rows - 2 downto 0 do
    for col = 0 to cols - 1 do
      let current_energy = energy_map.(row).(col) in
      let top_left = if col > 0 then Some (Array_2d.get ~arr:minimal_energy_map ~row:(row + 1) ~col:(col - 1)) else None in
      let top = Array_2d.get ~arr:minimal_energy_map ~row:(row + 1) ~col in
      let top_right = if col < cols - 1 then Some (Array_2d.get ~arr:minimal_energy_map ~row:(row + 1) ~col:(col + 1)) else None in
      let min_energy, direction =
        List.foldi [top_left; Some top; top_right] ~init:(Pair.get_energy (Option.value_exn top), 0) ~f:(fun i (min_energy, min_direction) neighbor_opt ->
          match neighbor_opt with
          | Some neighbor ->
            let new_energy = Pair.get_energy (Option.value_exn neighbor) in
            let dir = i - 1 in 
            if (Float.compare new_energy min_energy < 0) then (new_energy, dir) else (min_energy, min_direction)
          | None -> (min_energy, min_direction)
        )
      in
      let updated_energy = current_energy +. min_energy in
      minimal_energy_map.(row).(col) <- Pair.create ~in_energy:updated_energy ~in_direction:direction
    done
  done;
  minimal_energy_map

    
    let find_vertical_seam (minimal_energy_map : Minimal_energy_map.t) : int array =
      let rows, _ = Array_2d.dimensions minimal_energy_map in
      let start_col = Minimal_energy_map.get_minimal_energy minimal_energy_map 0 in
      let rec trace_seam row col seam =
        if row >= rows then seam 
        else 
          let direction = Pair.get_direction (Array_2d.get ~arr:minimal_energy_map ~row ~col 
          |> Option.value ~default:(Pair.create ~in_energy:0.0 ~in_direction:0)) in 
          let next_col = col + direction in 
          trace_seam (row + 1) next_col (col :: seam)
      in
      Array.of_list (List.rev (trace_seam 0 start_col []))

  let remove_vertical_seam (_image: image) (_seam: int array) : image =
    let height, width = Array_2d.dimensions _image in
    let new_width = width - 1 in
    Array_2d.init ~rows:height ~cols:new_width (fun y x ->
      if x < _seam.(y) then
        _image.(y).(x)
      else
        _image.(y).(x + 1)
    )
  
    