open Core
open Types

module Gif = struct
  let save_gif (frame: image) (_filename : string) : unit =
    let rows, cols = Array_2d.dimensions frame in
    let temp_filename = _filename ^ ".ppm" in
    Out_channel.with_file temp_filename ~f:(fun out ->
      Printf.fprintf out "P3\n%d %d\n255\n" cols rows;
      Array.iter frame ~f:(fun row ->
        Array.iter row ~f:(fun (r, g, b) ->
          Printf.fprintf out "%d %d %d " r g b
        );
        Printf.fprintf out "\n"
      )
    );

    ignore (Sys_unix.command (Printf.sprintf "magick convert %s %s" temp_filename _filename));
    Sys_unix.remove temp_filename

  let process_frames (_frames : 'a list) : 'a list =
    failwith "Not implemented: process_frames"

  let add_frame (_frame : image) (index : int): unit =
    let filename = Printf.sprintf "frames/frame_%03d.png" index in
    save_gif _frame filename

  let make_gif (_frames : image list) (_filename : string) : unit =
    ignore (Sys_unix.command "mkdir -p frames");
    List.iteri _frames ~f:(fun ind frame ->
      add_frame frame ind
    );
    let command = Printf.sprintf "magick convert -delay 10 -loop 0 frames/frame_*.png %s.gif" _filename in
    ignore (Sys_unix.command command);
    ignore (Sys_unix.command "rm -r frames") 
end

