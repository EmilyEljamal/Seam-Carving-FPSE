open Types

(** The [ImageProcess] module provides functionality for image manipulation, 
    including loading images, converting them to RGB pixel data, and processing energy maps. *)

module ImageProcess : sig
  (** [get_dimensions filename] retrieves the dimensions (width, height) of the image file. *)
  val get_dimensions : string -> int * int

  (** [convert_image_to_rgb filename] converts an image file to a raw RGB format and saves it as a temporary file. *)
  val convert_image_to_rgb : string -> string

  (** [convert_rgb_to_pixels ~temp_rgb_file ~width ~height] converts a raw RGB file into a pixel array. *)
  val convert_rgb_to_pixels : temp_rgb_file:string -> width:int -> height:int -> image

  (** [load_image filename] loads an image from a file and converts it into a pixel array. *)
  val load_image : string -> image

  (** [save_pixels_as_image ~pixels ~width ~height ~output_filename] saves a pixel array as an image file. *)
  val save_pixels_as_image : 
    pixels:image -> width:int -> height:int -> output_filename:string -> unit

  (** [fst3 (r, _, _)] retrieves the first component of an RGB tuple. *)
  val fst3 : pixel -> int

  (** [snd3 (_, g, _)] retrieves the second component of an RGB tuple. *)
  val snd3 : pixel -> int

  (** [trd3 (_, _, b)] retrieves the third component of an RGB tuple. *)
  val trd3 : pixel -> int

  (** [calculate_energy_map mask img] calculates the energy map of an image using gradient magnitude. *)
  val calculate_energy_map : (int * int) list option -> image -> energy_map

  (** [draw_seam img seam] highlights a seam in the image by drawing it in a specified color. *)
  val draw_seam : image -> int array -> image

  (** [remove_seam img seam width] removes a seam from the image, reducing its width by 1. *)
  val remove_seams : image -> int -> image list

  val add_seam : image -> int array -> image 

  val remove_object : image -> (int * int) list -> int array list -> int array list * image list

  val add_stored_seams : image -> int array list -> image list

  (* val add_seams : image -> int -> int -> image list *)
end
