open Types
open Direction

let hot_pink = { r = 255; g = 105; b = 180 }

module ImageProcess = struct
  
  let get_dimensions (filename: string): int * int =
    let command = Printf.sprintf "identify -format \"%%w %%h\" %s" filename in
    let ic = Unix.open_process_in command in
    let dimensions = input_line ic in
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
      { r; g; b }
    )
    in
    close_in ic;
    Sys.remove temp_rgb_file; 
    pixels

  let load_image (filename : string) : image =
      let width, height = get_dimensions filename in
      let temp_rgb_file = convert_image_to_rgb filename in
      convert_rgb_to_pixels ~temp_rgb_file ~width ~height
      
  let calculate_energy_map ~(object_removal: bool) (mask: (int * int) list option) (img: image) : energy_map =
    let rows, cols = Array_2d.dimensions img in
    let is_in_mask x y =
      match mask with
      | None -> false
      | Some mask_vals -> List.exists (fun (r, c) -> r = x && c = y) mask_vals
    in
    Array_2d.init ~rows ~cols (fun x y ->
      if object_removal && is_in_mask x y then
        Energy.create Float.neg_infinity
      else
        let directions = [West; East; North; South] in
        let neighbors = Array_2d.neighbors ~arr:img ~row:x ~col:y ~directions in
        Energy.calculate_pixel_energy ~neighbors
    )
      
    let draw_seam (img : image) (seam : int array) : image =
      let height, _ = Array_2d.dimensions img in

      if Array.length seam <> height then
        failwith (Printf.sprintf "Seam length mismatch: expected %d, got %d" height (Array.length seam));

      Array_2d.mapi (fun row col pixel ->
        if col = seam.(row) then hot_pink else pixel
      ) img

    let pad_image_with_black (img: image) (original_cols: int) : image =
      let black_pixel = { r = 0; g = 0; b = 0 } in
      let rows, cols = Array_2d.dimensions img in
      Array.init rows (fun i ->
        Array.init original_cols (fun j ->
          if j < cols then img.(i).(j) else black_pixel
        )
      )
    
    let remove_seams (img: image) (num_seams: int) : image list =
      let original_cols = Array.length img.(0) in  (* original image width *)
      let rec aux img remaining_seams =
        if remaining_seams = 0 then []
        else
          let energy_map = calculate_energy_map ~object_removal:false None img in
          let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
          let seam = Seam_identification.find_vertical_seam minimal_energy in
          let img_with_seam = draw_seam img seam in
          let img_without_seam = Seam_identification.remove_vertical_seam img seam in
          let padded_img = pad_image_with_black img_without_seam original_cols in
          img_with_seam :: padded_img :: (aux img_without_seam (remaining_seams - 1))
      in
      aux img num_seams

    let remove_object (img: image) (mask: (int * int) list) (seams: int array list) : (int array list * image list) =
      let original_cols = Array.length img.(0) in 
      let rec aux img mask seams_list = 
        if List.is_empty mask then (seams_list, [])
        else
          let energy_map = calculate_energy_map ~object_removal:true (Some mask) img in
          let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
          let seam = Seam_identification.find_vertical_seam minimal_energy in
          let img_with_seam = draw_seam img seam in
          let img_without_seam = Seam_identification.remove_vertical_seam img seam in
          let padded_img = pad_image_with_black img_without_seam original_cols in
          
          let updated_mask =
            List.filter (fun (row, col) -> col <> seam.(row)) mask
            |> List.map (fun (row, col) -> (row, col - 1))
          in
          
          let (new_seams, images) = aux img_without_seam updated_mask (seam :: seams_list) in 
          (new_seams, img_with_seam :: padded_img :: images)
        in aux img mask seams

    let add_seam (img: image) (seam_idx: int array) : image =
      let rows, cols = Array_2d.dimensions img in
      Array_2d.init ~rows ~cols:(cols + 1) (fun row col ->
        if col < seam_idx.(row) then
          img.(row).(col)
        else if col = seam_idx.(row) then
          let left = img.(row).(col) in
          let right = if col + 1 < cols then img.(row).(col + 1) else left in
          { r = (left.r + right.r) / 2; g = (left.g + right.g) / 2; b = (left.b + right.b) / 2 }
        else
          img.(row).(col - 1)
      )
      
      let rec add_seams (img: image) (width: int) (new_width: int) (previous_seam: int array option) : image list =
        if width = new_width then []
        else
          let energy_map = calculate_energy_map ~object_removal:false None img in

          let penalized_energy_map = match previous_seam with
          | Some seam -> 
              Array_2d.mapi (fun row col energy ->
                  if col = seam.(row) || 
                    (col = seam.(row) - 1) || 
                    (col = seam.(row) + 1) 
                  then Float.neg_infinity else energy
              ) energy_map
          | None -> energy_map
          in

          let minimal_energy_map = Seam_identification.calc_minimal_energy_to_bottom penalized_energy_map in
          let seam = Seam_identification.find_vertical_seam minimal_energy_map in
          let drawn_img = draw_seam img seam in
          let updated_img = add_seam img seam in
          drawn_img :: updated_img :: add_seams updated_img width (new_width + 1) (Some seam)
end




(* let rec remove_seams (img: image) (num_seams: int) : image list =
      if num_seams = 0 then []
      else
        let energy_map = calculate_energy_map ~object_removal:false None img in
        let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
        let seam = Seam_identification.find_vertical_seam minimal_energy in
        let img_with_seam = draw_seam img seam in
        let img_without_seam = Seam_identification.remove_vertical_seam img seam in
        img_with_seam :: img_without_seam :: (remove_seams img_without_seam (num_seams - 1)) *)

    (* *)

    (* 
    
    let rec add_stored_seams (img: image) (seams: int array list) : image list = 
      match seams with 
      | [] -> []
      | seam :: rest -> 
        let drawn_img = draw_seam img seam in
        let img_with_seam = add_seam img seam in 
        drawn_img :: img_with_seam :: (add_stored_seams img_with_seam rest)  *)
(* 
        let save_pixels_as_image ~pixels ~width ~height ~output_filename =
          let temp_rgb_file = Filename.temp_file "screenshot" ".rgb" in
          let oc = open_out_bin temp_rgb_file in
          
          (* Add padding with black pixels if the width is smaller than the original width *)
          let black_pixel = { r = 0; g = 0; b = 0 } in
        
          Array.iter (fun row ->
            let padded_row = Array.init width (fun col ->
              if col < Array.length row then row.(col) else black_pixel
            ) in
            Array.iter (fun { r; g; b } ->
              output_byte oc r;
              output_byte oc g;
              output_byte oc b
            ) padded_row
          ) pixels;
          close_out oc;
          let command = 
            Printf.sprintf "magick -size %dx%d -depth 8 rgb:%s %s"
              width height temp_rgb_file output_filename
          in
          if Sys.command command <> 0 then
            failwith "Failed to save screenshot";
          Sys.remove temp_rgb_file *)