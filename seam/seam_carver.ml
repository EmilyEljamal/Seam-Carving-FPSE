(* Function to apply a color change using ImageMagick *)
let color_frame output_filename color =
  let command =
    Printf.sprintf "magick convert -size 100x100 xc:%s %s" color output_filename
  in
  ignore (Sys.command command)

(* Function to save each frame with a cycling color *)
let save_frame frame_num =
  let filename = Printf.sprintf "frames/frame_%03d.png" frame_num in
  (* Cycle through red, white, blue *)
  let color = match frame_num mod 3 with
    | 0 -> "red"
    | 1 -> "white"
    | 2 -> "blue"
    | _ -> "black"  (* default fallback, although mod 3 should cover cases *)
  in
  color_frame filename color

(* Main function to process the image *)
let process_image num_steps =
  (* Ensure the frames directory exists *)
  ignore (Sys.command "mkdir -p frames");
  
  (* Save frames with alternating colors *)
  for step = 0 to num_steps - 1 do
    save_frame step
  done;

  (* Use ImageMagick's magick convert command to compile frames into a GIF *)
  let _ = Sys.command "magick convert -delay 10 -loop 0 frames/frame_*.png output.gif" in
  print_endline "GIF created as output.gif"

(* Entry point to run from the command line *)
let () =
  if Array.length Sys.argv <> 2 then
    Printf.eprintf "Usage: %s <num_steps>\n" Sys.argv.(0)
  else
    let num_steps = int_of_string Sys.argv.(1) in
    process_image num_steps


