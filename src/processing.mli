val process_image : input_path:string -> num_seams:int -> output_path:string -> unit
(** [process_image ~input_path ~num_seams ~output_path] processes the input image,
    removes the specified number of seams, and saves the resulting GIF to the output path. *)
