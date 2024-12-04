open Types

type pixel = int * int * int

type image = pixel Array_2d.t

module ImageProcess = struct
  let load_image (_filename : string) : image =
    failwith "Not implemented: load_image"

  let save_frame (_img : image) (_index : int) : unit =
    failwith "Not implemented: save_frame"

    let fst3 (r, _, _) = r
    let snd3 (_, g, _) = g
    let trd3 (_, _, b) = b

    let calculate_energy_map (img : image) : energy_map =
      let rows, cols = Array_2d.dimensions img in
      Array_2d.init rows cols (fun x y ->
        let get_neighbor offset_x offset_y =
          Array_2d.get img (x + offset_x) (y + offset_y)
          |> Option.value ~default:(0, 0, 0)  
      in

      let left = get_neighbor 0 (-1) in
      let right = get_neighbor 0 1 in
      let up = get_neighbor (-1) 0 in
      let down = get_neighbor 1 0 in

      let dx_r = fst3 right - fst3 left in
      let dx_g = snd3 right - snd3 left in
      let dx_b = trd3 right - trd3 left in
      let dx2 = (dx_r * dx_r) + (dx_g * dx_g) + (dx_b * dx_b) in

      let dy_r = fst3 down - fst3 up in
      let dy_g = snd3 down - snd3 up in
      let dy_b = trd3 down - trd3 up in
      let dy2 = (dy_r * dy_r) + (dy_g * dy_g) + (dy_b * dy_b) in

      Float.of_int (dx2 + dy2)
    )
    
  let draw_seam (_img : image) (_seam : int array) : image =
    failwith "Not implemented: draw_seam"

  let copy_image (_img : image) : image =
    failwith "Not implemented: copy_image"
end

