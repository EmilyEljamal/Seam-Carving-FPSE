let process_image ~input_path ~num_seams ~output_path =
  let original_image = Image_process.ImageProcess.load_image input_path in
  let result_images = Image_process.ImageProcess.remove_seams original_image num_seams in
  Gif.Gif.make_gif result_images output_path;
  Printf.printf "Saved processed GIF to %s\n" output_path
