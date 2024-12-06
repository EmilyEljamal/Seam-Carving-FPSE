[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
open Core

let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams_str :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams_str in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      let result_images = Image_process.ImageProcess.remove_seams original_image num_seams [] in
      (* Still need to process these modified images as a gif then save to user's output path *)
      (); (* Temporary unit placeholder *)
    )
| _ ->
  Printf.printf "No image path provided" 

(*
  load image
  calculate energy map
  calculate minimal energy to the bottom
  get vertical seam
  remove seam
*)