open Core
open Types

let load_image_or_exit path =
  try Image_process.ImageProcess.load_image path with
  | _ -> failwithf "Error: Failed to load image from path: %s. Please check the file and try again." path ()

let seam_removal input_path output_path =
  try
    let original_image = load_image_or_exit input_path in
    let image_rows, image_cols = Array_2d.dimensions original_image in

    Printf.printf "Enter the amount of seams you'd like to remove <int>:\n";
    let num_seams_str = Stdlib.read_line () in
    let num_seams =
      try int_of_string num_seams_str with
      | _ -> failwith "Error: num_seams must be an integer."
    in

    if num_seams < 0 || num_seams > image_rows || num_seams > image_cols then
      failwith (Printf.sprintf "Error: num_seams (%d) is negative or exceeds image dimensions (rows: %d, cols: %d)." num_seams image_rows image_cols);

    let vertical_images =
      Image_process.ImageProcess.remove_seams original_image num_seams Orientation.Vertical
    in
    let last_vertical_image = List.last vertical_images |> Option.value_exn ~message:"Error: No images generated during seam removal." in

    let horizontal_images =
      Image_process.ImageProcess.remove_seams last_vertical_image num_seams Orientation.Horizontal
    in

    let all_images = vertical_images @ horizontal_images in
    let final_image = List.last all_images |> Option.value_exn ~message:"Error: No final image produced." in

    Gif.Gif.make_gif all_images output_path final_image;
    Printf.printf "Seam removal completed. Saved resulting GIF to %s\n" output_path
  with
  | Failure msg -> Printf.eprintf "%s\n" msg; exit 1

let parse_range range_str =
  try
    match String.split ~on:'-' range_str with
    | [start_str; end_str] ->
        let start_ = int_of_string start_str in
        let end_ = int_of_string end_str in
        if start_ > end_ then failwith "Start index must be less than or equal to end index.";
        (start_, end_)
    | _ -> failwith "Error: Invalid range format. Use <start>-<end>."
  with
  | Failure msg -> failwithf "Error parsing range: %s\n" msg ()

let validate_mask mask image_rows image_cols =
  List.filter mask ~f:(fun (row, col) ->
      if row < 0 || col < 0 || row >= image_rows || col >= image_cols then (
        Printf.printf "Warning: Mask coordinate (%d, %d) is out of bounds \n" row col;
        false
      ) else true)

let parse_mask mask_str =
  try
    match String.split ~on:';' mask_str with
    | [row_range; col_range] ->
        let (row_start, row_end) = parse_range row_range in
        let (col_start, col_end) = parse_range col_range in
        List.concat_map (List.range row_start (row_end + 1)) ~f:(fun row ->
            List.map (List.range col_start (col_end + 1)) ~f:(fun col -> (row, col)))
    | _ -> failwith "Error: Invalid mask format. Use <row_start>-<row_end>;<col_start>-<col_end>."
  with
  | Failure msg -> failwithf "Error parsing mask: %s\n" msg ()

let object_removal input_path output_path =
  try
    Printf.printf "Enter mask range as <row_start>-<row_end>;<col_start>-<col_end>:\n";
    let mask_str = Stdlib.read_line () in
    let mask = parse_mask mask_str in
    let original_image = load_image_or_exit input_path in
    let image_rows, image_cols = Array_2d.dimensions original_image in

    if List.is_empty mask then failwith "Error: The mask is empty. Please specify a valid mask range.";

    let valid_mask = validate_mask mask image_rows image_cols in

    if List.is_empty valid_mask then failwith "Error: All mask coordinates are out of bounds.";

    let _, result_images = Image_process.ImageProcess.remove_object original_image mask [] in
    let final_image =
      List.last result_images |> Option.value_exn ~message:"Error: No final image produced."
    in
    Gif.Gif.make_gif result_images output_path final_image;
    Printf.printf "Object removal completed. Saved resulting GIF to %s\n" output_path
  with
  | Failure msg -> Printf.eprintf "%s\n" msg; exit 1

let () =
  try
    match Sys.get_argv () |> Array.to_list with
    | _ :: "seam_removal" :: input_path :: output_path :: [] ->
        seam_removal input_path output_path
    | _ :: "object_removal" :: input_path :: output_path :: [] ->
        object_removal input_path output_path
    | _ ->
        Printf.printf "Usage:\n";
        Printf.printf "  Seam Removal: seam_removal <input_path> <num_seams> <output_path>\n";
        Printf.printf "  Object Removal: object_removal <input_path> <output_path>\n";
        exit 1
  with
  | Failure msg -> Printf.eprintf "%s\n" msg; exit 1
