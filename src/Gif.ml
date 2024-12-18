open Core
open Types

module Gif = struct

  let save_gif (frame: image) (_filename : string) : unit =
    let rows, cols = Array_2d.dimensions frame in
    let temp_filename = _filename ^ ".ppm" in
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
  
    ignore (Sys_unix.command (Printf.sprintf "magick convert %s %s" temp_filename _filename));
    Sys_unix.remove temp_filename

  let add_frame (_frame : image) (index : int): unit =
    let filename = Printf.sprintf "frames/frame_%03d.ppm" index in
    save_gif _frame filename

  let make_gif (_frames : image list) (_filename : string) : unit =
    ignore (Sys_unix.command "mkdir -p frames");
    List.iteri _frames ~f:(fun ind frame ->
      add_frame frame ind
    );
    let command = Printf.sprintf "magick convert -delay 10 -loop 0 frames/frame_*.ppm %s.gif" _filename in
    ignore (Sys_unix.command command);
    ignore (Sys_unix.command "rm -r frames") 
end
