open Core
open Types

let load_image_or_exit path =
  match Image_process.ImageProcess.load_image path with
  | exception _ -> failwithf "Failed to load image from path: %s" path ()
  | image -> image

let seam_removal input_path num_seams_str output_path =
    let num_seams = int_of_string num_seams_str in
    let original_image = Image_process.ImageProcess.load_image input_path in 
    
    let vertical_images = Image_process.ImageProcess.remove_seams 
      original_image num_seams Orientation.Vertical 
    in

    let last_vertical_image = List.last_exn vertical_images in
    let horizontal_images = Image_process.ImageProcess.remove_seams 
      last_vertical_image num_seams Orientation.Horizontal
    in

    let all_images = vertical_images @ horizontal_images in
    let final_image =
      match List.rev all_images |> List.hd with
      | None -> failwith "No resulting images from object removal"
      | Some img -> img
    in
    Gif.Gif.make_gif all_images output_path final_image;
    Printf.printf "Saved resulting GIF to %s\n" output_path

  let parse_range range_str =
    match String.split ~on:'-' range_str with
    | [start_str; end_str] ->
        let start_ = int_of_string start_str in
        let end_ = int_of_string end_str in
        (start_, end_)
    | _ -> failwithf "Invalid range format: %s" range_str ()
    
  let parse_mask mask_str =
    match String.split ~on:';' mask_str with
    | [row_range; col_range] ->
        let (row_start, row_end) = parse_range row_range in
        let (col_start, col_end) = parse_range col_range in
        List.concat_map (List.range row_start (row_end + 1)) ~f:(fun row ->
            List.map (List.range col_start (col_end + 1)) ~f:(fun col -> (row, col)))
    | _ -> failwithf "Invalid mask format: %s" mask_str ()

  let object_removal input_path output_path =
    Printf.printf "Enter mask range as row_start-row_end;col_start-col_end:\n";
    let mask_str = Stdlib.read_line () in
    let mask = parse_mask mask_str in
    Printf.printf "Loading in image!\n";
    let original_image = load_image_or_exit input_path in
    Printf.printf "Loaded image for object removal\n";
    let _, result_images = Image_process.ImageProcess.remove_object original_image mask [] in
    let final_image =
      match List.rev result_images |> List.hd with
      | None -> failwith "No resulting images from object removal"
      | Some img -> img
    in
    Gif.Gif.make_gif result_images output_path final_image;
    Printf.printf "Saved resulting GIF to %s\n" output_path

let () =
  match Sys.get_argv () |> Array.to_list with
  | _ :: "seam_removal" :: input_path :: num_seams :: output_path :: [] ->
      seam_removal input_path num_seams output_path
  | _ :: "object_removal" :: input_path :: output_path :: [] ->
      object_removal input_path output_path
  | _ ->
      Printf.printf "Usage:\n";
      Printf.printf "  Seam Removal: seam_removal <input_path> <num_seams> <output_path>\n";
      Printf.printf "  Object Removal: object_removal <input_path> <output_path>\n";
      exit 1
