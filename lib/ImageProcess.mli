open Types

module ImageProcess : sig
    val load_image : string -> image
    (** [load_image filename] loads an image from a file.
        - [filename]: The name of the file containing the image.
        - Returns: The loaded image. *)

    val save_frame : image -> int -> unit
    (** [save_frame img index] saves a specific frame during the seam carving process for GIF creation.
        - [img]: The image to save as a frame.
        - [index]: The index number to distinguish the frame. *)

    val calculate_energy_map : image -> energy_map
    (** [calculate_energy_map img] calculates the energy map for a given image, which is used to determine
        the importance of each pixel during seam carving.
        - [img]: The input image.
        - Returns: The energy map for the image. *)

    val draw_seam : image -> int array -> image
    (** [draw_seam img seam] overlays a seam path on an image for visualization.
        - [img]: The image on which to draw the seam.
        - [seam]: An array of column indices representing the seam path for each row in the image.
        - Returns: The image with the seam drawn. *)

    val copy_image : image -> image
    (** [copy_image img] creates a deep copy of an image.
        - [img]: The input image to copy.
        - Returns: A new image that is a copy of the input. *)
end