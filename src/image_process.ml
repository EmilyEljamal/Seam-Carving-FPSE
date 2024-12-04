open Types
type pixel = int * int * int  (* Represented as (R, G, B) *)
type image = pixel array array  (* 2D array of pixels *)
let hot_pink = (255, 105, 180)
(* Note: must save width and height and update it accordingly whenever a seam is removed *)
(* Need to update image array type *)


module ImageProcess = struct

  let get_dimensions (filename: string) =
    let command = Printf.sprintf "identify -format \"%%w %%h\" %s" filename in
    let ic = Unix.open_process_in command in
    let dimensions = input_line ic in
    (* ignore (Unix.close_process_in ic); *)
    match String.split_on_char ' ' dimensions with
    | [width; height] -> (int_of_string width, int_of_string height)
    | _ -> failwith "Failed to parse dimensions"

  let convert_image_to_rgb (filename: string) =
    let temp_rgb_file = Filename.temp_file "image" ".rgb" in
    let command = Printf.sprintf "magick %s -depth 8 rgb:%s" filename temp_rgb_file in
    if Sys.command command <> 0 then
      failwith "Failed to convert image to raw RGB";
    temp_rgb_file

  let convert_rgb_to_pixels (temp_rgb_file: string) (width: int) (height: int): image =
    let ic = open_in_bin temp_rgb_file in
    let pixels = Array_2d.init height width (fun x ->
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
      let pixels = convert_rgb_to_pixels temp_rgb_file width height in
      pixels
    
  let save_pixels_as_image (pixels: image) (width: int) (height: int) (output_filename: string) =
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
  

  let calculate_energy_map (_img : image) : energy_map =
    failwith "Not implemented: calculate_energy_map"

    let draw_seam (img : image) (seam : int array) : image =
        Array.mapi (fun y row ->
          Array.mapi (fun x pixel ->
            if x = seam.(y) then hot_pink else pixel
          ) row
        ) img


    let remove_seam (img: image) (seam: int array) (width: int): image =
      let new_width = width - 1 in
      Array.mapi (fun y row ->
        Array.init new_width (fun x ->
          if x = seam.(y) then row.(x) else row.(x + 1)
        )
      ) img;


end