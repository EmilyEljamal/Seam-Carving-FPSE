open Types
open Orientation

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

  (** [calculate_energy_map mask img] calculates the energy map of an image using gradient magnitude. *)
  val calculate_energy_map : object_removal:bool -> (int * int) list option -> image -> energy_map

  (** [draw_seam img seam] highlights a seam in the image by drawing it in a specified color. *)
  val draw_seam : image -> int array -> image

  (** [pad_image_with_black img ~target_rows ~target_cols] pads the given image 
      to the specified target rows and columns, filling extra space with black pixels. 
  *)
  val pad_image_with_black : image -> target_rows:int -> target_cols:int -> image

  (** [perform_seam_removal image remaining_seams target_rows target_cols] performs seam removal 
      recursively on the given image while padding it back to the original dimensions.
  *)
  val perform_seam_removal : image -> int -> int -> int -> image list

  (** [remove_seams image num_seams orientation] removes the specified number of seams 
      from the given image based on the orientation (Vertical or Horizontal). 
  *)
  val remove_seams : image -> int -> orientation -> image list




    (* * [save_pixels_as_image ~pixels ~width ~height ~output_filename] saves a pixel array as an image file.
    val save_pixels_as_image : 
    pixels:image -> width:int -> height:int -> output_filename:string -> unit *)

  (* val add_seam : image -> int array -> image 

  val remove_object : image -> (int * int) list -> int array list -> int array list * image list

  val add_stored_seams : image -> int array list -> image list

  val add_seams : image -> int -> int -> image list  *)
end
