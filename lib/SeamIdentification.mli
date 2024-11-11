open Types

(* Energy map type: Represents the energy of each pixel in the image *)
type energy_map = float array array


module type EnergyMap = sig
type energy_map = float array array
  val edge_detection: image -> energy_map
end

(* Module type for calculating the minimal energy to the bottom, with memoization. *)
module type MinimalEnergyToBottomMap = sig
include EnergyMap
    (* copy first bottom row of energy 0-1, then iterate bottom to top, left to right,
    for each cell, check the -1,0,1 lower row cells and save minimized value to cell + direction number *)
    (* Array of Pairs (value, direction) *)

    val float_to_pair: energy_map -> minimal_energy_map

    val pair_to_float: minimal_energy_map -> energy_map

    (** [calc_minimal_energy_to_bottom energy_map] calculates the minimal energy required 
      to reach the bottom from each pixel in the energy map. This is a memoized function. *)
    val calc_minimal_energy_to_bottom: minimal_energy_map -> minimal_energy_map


end
(* Module type for basic seam carving operations. *)
module type SeamCarver = sig
include MinimalEnergyToBottomMap
  (** [find_vertical_seam energy_map] finds the vertical seam with minimal energy. *)
  val find_vertical_seam : minimal_energy_map -> int list

  (** [remove_vertical_seam image seam] removes the specified vertical seam from the image. *)
  val remove_vertical_seam : image -> int list -> image
end

module type MakeSeamCarver = functor (M : EnergyMap) -> SeamCarver

(* Functor for creating a seam carver module instance with basic implementation. *)
module Make : MakeSeamCarver