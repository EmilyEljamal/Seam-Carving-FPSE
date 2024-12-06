[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
open Core

let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: num_seams :: output_path :: [] -> 
    (
      let num_seams = int_of_string num_seams in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      let energy_map = Image_process.ImageProcess.calculate_energy_map original_image in
      let minimal_energy = Seam_identification.calc_minimal_energy_to_bottom energy_map in
      let vertical_seam = Seam_identification.find_vertical_seam minimal_energy in
      let modified_images = Image_process.ImageProcess.remove_seam original_image vertical_seam in
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