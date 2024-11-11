open Types

module ImageProcess : sig
    val load_image : string -> image

    val save_frame : image -> int -> unit

    val calculate_energy_map : image -> energy_map
end

