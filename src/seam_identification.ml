open Types
open Core


let calc_minimal_energy_to_bottom (energy_map: energy_map) : Minimal_energy_map.t =
    let rows, cols = Array_2d.dimensions energy_map in
    Array_2d.init ~rows ~cols (fun row col ->
      if row = rows - 1 then
        Pair.create ~in_energy:energy_map.(row).(col) ~in_direction:0
      else
        let neighbors = Array_2d.bottom_neighbors ~arr:energy_map ~row ~col in
        let min_neighbor_energy, direction =
          List.mapi neighbors ~f:(fun idx e -> (e, idx - 1)) (* Indices -1, 0, 1 *)
          |> List.min_elt ~compare:(fun (e1, _) (e2, _) -> Float.compare e1 e2)
          |> Option.value_exn
        in
        let new_energy = energy_map.(row).(col) +. min_neighbor_energy in
        Pair.create ~in_energy:new_energy ~in_direction:direction
    )
    
  let find_vertical_seam (minimal_energy_map: Minimal_energy_map.t) : int array =
    let rows, _cols = Array_2d.dimensions minimal_energy_map in
    let rec extract_path row col path =
      if row >= rows then List.rev path
      else
        let direction = Array_2d.get ~arr:minimal_energy_map ~row ~col
                        |> Option.value_exn
                        |> Pair.get_direction
        in
        extract_path (row + 1) (col + direction) (col :: path)
    in
    let start_col = Minimal_energy_map.get_minimal_energy minimal_energy_map 0 in
    Array.of_list (extract_path 0 start_col [])
  

  let remove_vertical_seam (_image: image) (_seam: int array) : image =
    let height, width = Array_2d.dimensions _image in
    let new_width = width - 1 in
    Array_2d.init ~rows:height ~cols:new_width (fun y x ->
      if x < _seam.(y) then
        _image.(y).(x)
      else
        _image.(y).(x + 1)
    )
