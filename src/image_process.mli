open Types

module ImageProcess : sig

    (** [get_dimensions filename] returns the width and height of the image
        specified by [filename]. *)
    val get_dimensions : string -> int * int
  
    (** [load_image filename] loads an image from the specified [filename] and
        returns a 2D array of pixels representing the image. *)
    val load_image : string -> image
  
    (** [save_pixels_as_image pixels width height output_filename] saves a 2D array
        of pixels as an image with the given [width] and [height] to the specified
        [output_filename]. *)
    val save_pixels_as_image : 
      image -> int -> int -> string -> unit
  
    (** [draw_seam img seam] takes an image [img] and an array [seam] representing
        the indices of a vertical seam to highlight, and returns a new image with
        the seam drawn in hot pink. *)
    val draw_seam : image -> int array -> image
  
    (** [remove_seam img seam] removes the specified seam from the image [img]. *)
    val remove_seam : image -> int array -> image
  
  end
  