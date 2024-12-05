open Types

module ImageProcess : sig

    (** [get_dimensions filename] returns the width and height of the image
        specified by [filename]. *)
    val get_dimensions : filename: string -> int * int

    val convert_image_to_rgb : filename: string -> string

    val convert_rgb_to_pixels : temp_rgb_file: string -> width: int -> height: int -> image
  
    (** [load_image filename] loads an image from the specified [filename] and
        returns a 2D array of pixels representing the image. *)
    val load_image : filename: string -> image

    val calculate_energy_map : img : image -> energy_map
  
    (** [save_pixels_as_image pixels width height output_filename] saves a 2D array
        of pixels as an image with the given [width] and [height] to the specified
        [output_filename]. *)
    val save_pixels_as_image : 
      pixels: image -> width: int -> height: int -> filename: string -> unit
  
    (** [draw_seam img seam] takes an image [img] and an array [seam] representing
        the indices of a vertical seam to highlight, and returns a new image with
        the seam drawn in hot pink. *)
    val draw_seam : img: image -> seam: int array -> image
  
    (** [remove_seam img seam] removes the specified seam from the image [img]. *)
    val remove_seam : img: image -> seam: int array -> image
  
  end
  