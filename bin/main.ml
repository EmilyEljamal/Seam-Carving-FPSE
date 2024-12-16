[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
open Core

let () = 
  match Sys.get_argv () |> Array.to_list with
  | _ :: input_path :: output_path :: [] -> 
    ( 
      let mask =
        let rows = List.init 60 ~f:(fun i -> i + 450) in
        let cols = List.init 30 ~f:(fun i -> i + 790) in
        List.concat (List.map rows ~f:(fun x -> List.map cols ~f:(fun y -> (x, y)))) in
      let original_image = Image_process.ImageProcess.load_image input_path in 
      Printf.printf "Image loaded\n";
      let seams, result_images = Image_process.ImageProcess.remove_object original_image mask [] in
      (* let first_image = List.hd result_images in
      let original_rows, original_cols = Types.Array_2d.dimensions (Option.value_exn first_image) in
      let new_rows, new_cols = Types.Array_2d.dimensions (Option.value_exn final_image) in *)
      let final_image = List.hd (List.rev result_images) in 
      let updated_images_with_seams = Image_process.ImageProcess.add_stored_seams (Option.value_exn final_image) seams  in (* Combine all resulting images into one list *) 
      let all_result_images = result_images @ updated_images_with_seams in
      (*let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
      Still need to process these modified images as a gif then save to user's output path *)
      Gif.Gif.make_gif all_result_images output_path

      ) (* Temporary unit placeholder *)
| _ ->
  Printf.printf "No image path provided" 

(*
  load image
  calculate energy map
  calculate minimal energy to the bottom
  get vertical seam
  remove seam
*)