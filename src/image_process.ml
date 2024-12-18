open Types
open Direction
open Orientation
(* open Core *)

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
        Float.neg_infinity
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

  let pad_image_with_black (img: image) ~target_rows ~target_cols : image =
    let rows, cols = Array_2d.dimensions img in
    Array_2d.init ~rows:target_rows ~cols:target_cols (fun row col ->
      if row < rows && col < cols then img.(row).(col)
      else { r = 0; g = 0; b = 0 }  (* Black pixel for padding *)
    )
    
  let rec perform_seam_removal (image: image) (remaining_seams: int) (target_rows: int) (target_cols: int) : image list =
    if remaining_seams = 0 then []
    else
      let energy_map = calculate_energy_map ~object_removal:false None image in
      let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
      let seam = Seam_identification.find_vertical_seam minimal_energy in
      let image_with_seam = draw_seam image seam in
      let image_without_seam = Seam_identification.remove_vertical_seam image seam in

      let padded_image = pad_image_with_black image_without_seam ~target_rows ~target_cols in
      image_with_seam :: padded_image :: 
      (perform_seam_removal image_without_seam (remaining_seams - 1) target_rows target_cols)

  let remove_seams (image: image) (num_seams: int) (orientation: Orientation.orientation) : image list =
    match orientation with
    | Vertical ->
        let original_rows, original_cols = Array_2d.dimensions image in
        perform_seam_removal image num_seams original_rows original_cols
    | Horizontal ->
        let original_rows, original_cols = Array_2d.dimensions image in
        let transposed_image = Array_2d.transpose image in
        let transposed_results = perform_seam_removal transposed_image num_seams original_cols original_rows in
        List.map Array_2d.transpose transposed_results
  
  let remove_object (img: image) (mask: (int * int) list) (seams: int array list) : (int array list * image list) =
    let original_rows, original_cols = Array_2d.dimensions img in 
    let rec aux img mask seams_list = 
      if List.is_empty mask then (seams_list, [])
      else
        let energy_map = calculate_energy_map ~object_removal:true (Some mask) img in
        let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
        let seam = Seam_identification.find_vertical_seam minimal_energy in
        let img_with_seam = draw_seam img seam in
        let img_without_seam = Seam_identification.remove_vertical_seam img seam in
        let padded_img = pad_image_with_black img_without_seam ~target_rows:original_rows ~target_cols:original_cols in
        
        let updated_mask =
          List.filter (fun (row, col) -> col <> seam.(row)) mask
          |> List.map (fun (row, col) -> (row, col - 1))
        in 
        let (new_seams, images) = aux img_without_seam updated_mask (seam :: seams_list) in 
        (new_seams, img_with_seam :: padded_img :: images)
      in aux img mask seams
end


