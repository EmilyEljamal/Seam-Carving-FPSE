module Gif : sig
    val save_gif : string -> int -> unit

    (* process frames *)
    val process_frames : 'a list -> 'a list

    (* make gif *)
    val make_gif : 'a list -> string -> unit
end 