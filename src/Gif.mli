open Types

module Gif : sig
    val save_gif : image -> string -> unit
    (** [save_gif filename] saves the currently processed frames to the person's specified pathname.
        - [path]: The output path for GIF file to be saved. *)

    val add_frame : image -> int -> unit
    (** [add_frame frame] adds a single frame to the GIF sequence. *)

    val make_gif : image list -> string -> image -> unit
    (** [make_gif frames filename] creates a GIF file from a list of frames. *)


end 