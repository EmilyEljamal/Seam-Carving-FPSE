open Types

(** [calc_minimal_energy_to_bottom energy_map] calculates the minimal energy required 
    to reach the bottom from each pixel in the energy map. memoized function. *)
val calc_minimal_energy_to_bottom: energy_map -> Minimal_energy_map.t

(** [find_vertical_seam minimal_energy_map] finds the vertical seam with minimal energy. *)
val find_vertical_seam : Minimal_energy_map.t -> int list

(** [remove_vertical_seam image seam] removes the specified vertical seam from the image. *)
val remove_vertical_seam : image -> int list -> image
