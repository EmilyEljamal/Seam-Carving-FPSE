[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
open Core


let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: output_path :: [] -> 
    ( 
      let mask =
        let rows = List.init 50 ~f:(fun i -> i + 190) in
        let cols = List.init 40 ~f:(fun i -> i + 290) in
        List.concat (List.map rows ~f:(fun x -> List.map cols ~f:(fun y -> (x, y)))) in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      Printf.printf "Image loaded\n";
      let seams, result_images = Image_process.ImageProcess.remove_object original_image mask [] in
      let final_image = Option.value_exn (List.hd (List.rev result_images)) in 
      (* let first_image = List.hd result_images in
      (* let original_rows, original_cols = Types.Array_2d.dimensions (Option.value_exn first_image) in *)
      let final_image = Option.value_exn (List.hd (List.rev result_images)) in  *)
      (* let new_rows, new_cols = Types.Array_2d.dimensions (final_image) in
      let updated_images_with_seams = Image_process.ImageProcess.add_seams (final_image) original_cols new_cols None  in  
      let all_result_images = result_images @ updated_images_with_seams in *)
      (*let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif result_images output_path final_image
      ) (* Temporary unit placeholder *)
| _ ->
  Printf.printf "No image path provided" 
(* let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams_str in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      (* Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif result_images output_path
      )
| _ ->
  Printf.printf "No image path provided"  *)




(* OBJECT REMOVAL MAIN ---  *)
(*
let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    let num_seams = int_of_string num_seams_str in
    let original_image = Image_process.ImageProcess.load_image input_path in 
    
    (* Remove vertical seams first *)
    let vertical_images = Image_process.ImageProcess.remove_seams 
      original_image num_seams Orientation.Vertical 
    in

    (* Use the last image from vertical as input for horizontal seams *)
    let last_vertical_image = List.last_exn vertical_images in
    let horizontal_images = Image_process.ImageProcess.remove_seams 
      last_vertical_image num_seams Orientation.Horizontal
    in

    (* Combine vertical and horizontal images into a single sequence *)
    let all_images = vertical_images @ horizontal_images in

    (* Save the combined images as a GIF *)
    Gif.Gif.make_gif all_images output_path

  | _ ->
      Printf.printf "Usage: <input_path> <num_seams> <output_path>\n" *)



(* let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams_str in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      (* Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif result_images output_path
      )
| _ ->
  Printf.printf "No image path provided" 

 *)


(* OBJECT REMOVAL MAIN ---  *)
(* 
let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams_str in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      Printf.printf "Image loaded\n";
      let seams, result_images = Image_process.ImageProcess.remove_object original_image mask [] in
      let final_image = Option.value_exn (List.hd (List.rev result_images)) in 
      let first_image = List.hd result_images in
      let original_rows, original_cols = Types.Array_2d.dimensions (Option.value_exn first_image) in
      let new_rows, new_cols = Types.Array_2d.dimensions ( final_image) in 
      let updated_images_with_seams = Image_process.ImageProcess.add_seams final_image original_cols new_cols  in (* Combine all resulting images into one list *) 
      let all_result_images = result_images @ updated_images_with_seams in
      (*let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif all_result_images output_path

      ) (* Temporary unit placeholder *)
| _ ->
  Printf.printf "No image path provided"  *)




(* OBJECT REMOVAL MAIN ---  *)
(* 
let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams_str in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      (* Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif result_images output_path; (* Temporary unit placeholder *)
    )
| _ ->
  Printf.printf "No image path provided"  *)

(*
  load image
  calculate energy map
  calculate minimal energy to the bottom
  get vertical seam
  remove seam
*)