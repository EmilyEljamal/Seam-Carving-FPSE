type image = Array_2d

type energy_map = Array_2d

module Pair :
  sig
    type t =
      { energy : float
      ; direction   : int } [@@deriving compare]

    val create : float -> int -> t
    (* Initialize a Pair with energy and direction. *)

    val get_energy : t -> float
    (* Retrieve the energy value. *)

    val get_direction : t -> int
    (* Retrieve the direction value. *)

    val update_energy : t -> float -> t
    (* Update the energy field in a Pair and return a new Pair. *)
  end

module Array_2d : 
sig 
    type 'a t = 'a array array

    val init : int -> int -> (int -> int -> 'a) -> 'a t
    (* Initialize a 2D array with dimensions and a function to set values. *)

    val get : 'a t -> int -> int -> 'a
    (* Retrieve an element from 2D array at specified row and column. *)

    val dimensions : 'a t -> int * int
    (* Get the dimensions of the 2D array. *)

    val adjacents : 'a t -> int -> int -> 'a list
    (* Retrieves a list of all adjacent elements (4 directions) around the element at (x, y). *)
end

module Minimal_energy_map :
sig
    type t = Pair.t Array_2d.t

    val from_energy_map : energy_map -> t
    (* Convert an energy_map (float Array_2d) to a minimal energy map (Pair Array_2d). *)

    val get_minimal_energy : t -> int -> int

    val update_direction : t -> int -> int -> int -> unit
    (* Update the direction in a minimal energy map cell. *)

    val to_energy_map : t -> energy_map
    (* Convert a minimal energy map back to an energy_map. *)
end