open Types

let hot_pink = (255, 105, 180)
(* Note: must save width and height and update it accordingly whenever a seam is removed *)


module ImageProcess = struct
  let get_dimensions (filename: string): int * int =
    let command = Printf.sprintf "identify -format \"%%w %%h\" %s" filename in
    let ic = Unix.open_process_in command in
    let dimensions = input_line ic in
    (* ignore (Unix.close_process_in ic); *)
    match String.split_on_char ' ' dimensions with
    | [width; height] -> (int_of_string width, int_of_string height)
    | _ -> failwith "Failed to parse dimensions"

  let convert_image_to_rgb (filename: string) : string =
    let temp_rgb_file = Filename.temp_file "image" ".rgb" in
    let command = Printf.sprintf "magick %s -depth 8 rgb:%s" filename temp_rgb_file in
    if Sys.command command <> 0 then
      failwith "Failed to convert image to raw RGB";
    temp_rgb_file

  let convert_rgb_to_pixels ~temp_rgb_file ~width ~height : image =
    let ic = open_in_bin temp_rgb_file in
    let pixels = Array_2d.init ~rows:height ~cols:width (fun _ _ ->
      let r = input_byte ic in
      let g = input_byte ic in
      let b = input_byte ic in
      (r, g, b) )
    in
    close_in ic;
    Sys.remove temp_rgb_file; 
    pixels

  let load_image (filename : string) : image =
      let width, height = get_dimensions filename in
      let temp_rgb_file = convert_image_to_rgb filename in
      let pixels = convert_rgb_to_pixels ~temp_rgb_file ~width ~height in
      pixels
    
  let save_pixels_as_image ~pixels ~width ~height ~output_filename =
    let temp_rgb_file = Filename.temp_file "screenshot" ".rgb" in
    let oc = open_out_bin temp_rgb_file in
    Array.iter (fun row ->
      Array.iter (fun (r, g, b) ->
        output_byte oc r;
        output_byte oc g;
        output_byte oc b
      ) row
    ) pixels;
    close_out oc;
    let command = 
      Printf.sprintf "magick -size %dx%d -depth 8 rgb:%s %s"
        width height temp_rgb_file output_filename
    in
    if Sys.command command <> 0 then
      failwith "Failed to save screenshot";
    Sys.remove temp_rgb_file
  

    let fst3 (r, _, _) = r
    let snd3 (_, g, _) = g
    let trd3 (_, _, b) = b

    let calculate_energy_map (mask : (int * int) list option) (img : image) : energy_map =
      let rows, cols = Array_2d.dimensions img in
  
      let is_in_mask x y =
        match mask with
        | None -> false
        | Some mask_list -> List.exists (fun (mx, my) -> mx = x && my = y) mask_list
      in
    
      Array_2d.init ~rows ~cols (fun x y ->
        if is_in_mask x y then
          Float.neg_infinity
        else
          let get_neighbor offset_x offset_y =
            Array_2d.get ~arr:img ~row:(x + offset_x) ~col:(y + offset_y)
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

    let draw_seam (img : image) (seam : int array) : image =
      let height, width = Array_2d.dimensions img in

      (* Debug output for dimensions *)
      Printf.printf "Dimensions during drawing seam: height = %d, width = %d\n" height width;
    
      (* Ensure the seam length matches the image height *)
      if Array.length seam <> height then
        failwith (Printf.sprintf "Seam length mismatch: expected %d, got %d" height (Array.length seam));
    
      (* Draw the seam *)
      Array_2d.mapi (fun row col pixel ->
        if col = seam.(row) then hot_pink else pixel
      ) img

      (* let print_minimal_energy_map (minimal_energy_map : Minimal_energy_map.t) : unit =
        let height, width = Array_2d.dimensions minimal_energy_map in
        for row = 0 to height - 1 do
          for col = 0 to width - 1 do
            match Array_2d.get ~arr:minimal_energy_map ~row ~col with
            | Some pair -> 
                let energy = Pair.get_energy pair in
                let direction = Pair.get_direction pair in
                Printf.printf "Energy at (%d, %d): %f, Direction: %d\n" row col energy direction
            | None -> 
                Printf.printf "Energy at (%d, %d) is out of bounds\n" row col
          done;
        done *)

        
    let rec remove_seams (img: image) (num_seams: int) : image list =
      if num_seams = 0 then []
      else
        let energy_map = calculate_energy_map None img in
        let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
        Printf.printf "One pass removing seam:\n";
        (* print_minimal_energy_map minimal_energy; *)
        let seam = Seam_identification.find_vertical_seam minimal_energy in
        let img_with_seam = draw_seam img seam in
        let img_without_seam = Seam_identification.remove_vertical_seam img seam in
        img_with_seam :: img_without_seam :: (remove_seams img_without_seam (num_seams - 1))

    let add_seam (img: image) (seam_idx: int array) : image =
      let rows, cols = Array_2d.dimensions img in
      let output = Array_2d.init ~rows ~cols:(cols + 1) (fun row col ->
        if col <= seam_idx.(row) then
          Array_2d.get ~arr:img ~row ~col |> Option.value ~default:(0,0,0)
        else if col = seam_idx.(row) + 1 then
          let left = Array_2d.get ~arr:img ~row ~col:(col - 1) |> Option.value ~default:(0,0,0) in
          let right = Array_2d.get ~arr:img ~row ~col:seam_idx.(row) |> Option.value ~default:(0,0,0) in
          let r = (fst3 left + fst3 right) / 2 in
          let g = (snd3 left + snd3 right) / 2 in
          let b = (trd3 left + trd3 right) / 2 in
          (r, g, b)
        else
          Array_2d.get ~arr:img ~row ~col:(col - 1) |> Option.value ~default:(0,0,0)
      )
      in
      output
    
    
    let rec remove_object (img: image) (mask: (int * int) list) (seams: int array list) : (int array list * image list) =
      if List.is_empty mask then (seams, [])
      else
        let energy_map = calculate_energy_map (Some mask) img in
        let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
        Printf.printf "One pass removing seam:\n";
        (* Visualize the minimal energy map if needed *)
        (* print_minimal_energy_map minimal_energy; *)
        
        let seam = Seam_identification.find_vertical_seam minimal_energy in
        let img_with_seam = draw_seam img seam in
        let img_without_seam = Seam_identification.remove_vertical_seam img seam in
        
        let updated_mask =
          List.filter (fun (row, col) -> col <> seam.(row)) mask
          |> List.map (fun (row, col) -> (row, col - 1))
        in
        
        let (new_seams, images) = remove_object img_without_seam updated_mask (seam :: seams) in 
        (new_seams, img_with_seam :: img_without_seam :: images)

    (* let rec add_seams (img: image) (width: int) (new_width: int) : image list =
      if (width = new_width) then []
      else 
        let energy = calculate_energy_map None img in
        let min_map = Seam_identification.calc_minimal_energy_to_bottom energy in
        let seam = Seam_identification.find_vertical_seam min_map in
        let drawn_img = draw_seam img seam in
        let img_with_seam = add_seam img seam in
        drawn_img :: img_with_seam :: (add_seams img_with_seam width (new_width + 1)) *)
          
        let rec add_stored_seams (img: image) (seams: int array list) : image list = 
          match seams with 
          | [] -> []
          | seam :: rest -> 
            let drawn_img = draw_seam img seam in
            let img_with_seam = add_seam img seam in 
            drawn_img :: img_with_seam :: (add_stored_seams img_with_seam rest)
end