(* open Imagelib *)

(* Function to apply some manipulation to the image. Placeholder for seam carving *)
let manipulate_image img step =
  (* Example manipulation: change colors as a placeholder for seam carving *)
  let new_img = Array.map Array.copy img in
  let factor = 1.0 -. (float_of_int step *. 0.05) in
  for y = 0 to Array.length new_img - 1 do
    for x = 0 to Array.length new_img.(y) - 1 do
      let (r, g, b) = new_img.(y).(x) in
      let new_r = int_of_float (float_of_int r *. factor) in
      let new_g = int_of_float (float_of_int g *. factor) in
      let new_b = int_of_float (float_of_int b *. factor) in
      new_img.(y).(x) <- (new_r, new_g, new_b)
    done
  done;
  new_img

(* Function to save each frame *)
let save_frame img frame_num =
  let filename = Printf.sprintf "frames/frame_%03d.png" frame_num in
  Image.write_file filename img

(* Main function to process the image *)
let process_image input_filename num_steps =
  (* Load the input image *)
  let img = Image.read_file input_filename in
  
  (* Apply transformations and save frames *)
  for step = 0 to num_steps - 1 do
    let modified_img = manipulate_image img step in
    save_frame modified_img step
  done;

  (* Use ImageMagick's convert command to compile frames into a GIF *)
  let _ = Sys.command "convert -delay 10 -loop 0 frames/frame_*.png output.gif" in
  print_endline "GIF created as output.gif"

(* Entry point to run from the command line *)
let () =
  if Array.length Sys.argv <> 3 then
    Printf.eprintf "Usage: %s <input_image> <num_steps>\n" Sys.argv.(0)
  else
    let input_filename = Sys.argv.(1) in
    let num_steps = int_of_string Sys.argv.(2) in
    process_image input_filename num_steps
