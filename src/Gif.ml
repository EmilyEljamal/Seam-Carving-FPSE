open Core
open Types

module Gif = struct

  let save_gif (frame: image) (filename : string) : unit =
    let rows, cols = Array_2d.dimensions frame in
    let temp_filename = filename ^ ".ppm" in
    let out_channel = Stdlib.open_out_bin temp_filename in
    Printf.fprintf out_channel "P6\n%d %d\n255\n" cols rows;
    Array.iter frame ~f:(fun row ->
      Array.iter row ~f:(fun {r; g; b} ->
        Stdlib.output_byte out_channel r;
        Stdlib.output_byte out_channel g;
        Stdlib.output_byte out_channel b;
      )
    );
    Stdlib.close_out out_channel;
  
    ignore (Sys_unix.command (Printf.sprintf "magick convert %s %s" temp_filename filename));
    Sys_unix.remove temp_filename

  let add_frame (frame : image) (index : int): unit =
    let filename = Printf.sprintf "frames/frame_%03d.ppm" index in
    save_gif frame filename

  let make_gif (frames : image list) (filename : string) (final_image: image) : unit =
    ignore (Sys_unix.command "mkdir -p frames");
    List.iteri frames ~f:(fun ind frame ->
      add_frame frame ind
    );
    let filename_img = filename ^ ".png" in
    save_gif final_image filename_img;
    let command = Printf.sprintf "magick convert -delay 10 -loop 0 frames/frame_*.ppm %s.gif" filename in
    ignore (Sys_unix.command command);
    ignore (Sys_unix.command "rm -r frames") 
end
