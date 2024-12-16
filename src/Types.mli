module Pair :
  sig
    type t =
      { energy : float
      ; direction   : int } [@@deriving compare]
    (** The [Pair] type holds data for energy and direction, representing a single cell in the minimal energy map. *)

    val create : in_energy: float -> in_direction: int -> t
    (** [create ~energy ~direction] initializes a Pair with the given energy and direction values. *)

    val get_energy : t -> float
    (** [get_energy pair] retrieves the energy value from a Pair. *)

    val get_direction : t -> int
    (** [get_direction pair] retrieves the direction value from a Pair. *)

    val update_energy : t -> float -> t
    (** [update_energy pair energy] updates the energy field in a Pair, returning a new Pair. *)
  end

module Array_2d : 
sig 
    type 'a t = 'a array array
    (** A 2D array type alias for general use in image and energy map representations. *)

    val init : rows: int -> cols: int -> (int -> int -> 'a) -> 'a t
    (** [init rows cols f] initializes a 2D array with the given dimensions, setting each element
        according to the function [f], which takes row and column indices.
        - [rows]: The number of rows.
        - [cols]: The number of columns.
        - [f]: A function defining how each element is initialized. *)

    val get : arr: 'a t -> row: int -> col: int -> 'a option
    (** [get arr x y] retrieves an element at the specified row and column in a 2D array. *)

    val get_row : 'a t -> int -> 'a array option
    (** [get_row arr x] retrieves the elements in a row at the specified row in a 2D array. *)

    val dimensions : 'a t -> int * int
    (** [dimensions arr] returns the dimensions (rows, cols) of a 2D array. *)

    val adjacents : arr: 'a t -> row: int -> col: int -> 'a list
    (** [adjacents arr x y] retrieves all adjacent elements in the four main directions (up, down, left, right)
        around the element at (x, y).
        - Returns: A list of adjacent elements. *)

        
    val bottom_neighbors : arr:'a t -> row:int -> col:int -> (int * 'a) list
    (** [bottom_neighbors ~arr ~row ~col] retrieves the bottom neighbors of the
        element at position [(row, col)] in [arr]. Each neighbor is returned as a
        tuple [(direction, value)], where:
        - [-1] represents the bottom-left neighbor (SW),
        - [0] represents the bottom neighbor (S),
        - [1] represents the bottom-right neighbor (SE).
        Neighbors that are out of bounds are excluded. *)

    val set : arr:'a t -> row:int -> col:int -> 'a -> unit
    (** [set ~arr ~row ~col value] updates the value at position [(row, col)] in the
        2D array to [value]. Raises [Invalid_argument] if the position is out of bounds. *)

    val map : (int -> int -> 'a -> 'b) -> 'a t -> 'b t
    (** [map f arr] applies the function [f] to each element in the 2D array [arr], returning a new 2D array. *)

    val mapi : (int -> int -> 'a -> 'b) -> 'a t -> 'b t 
    (** [mapi f arr] applies the function [f] to each element in the 2D array [arr], along with its row and column indices.
    - [f row col value]: A function that takes the row index [row], column index [col], and the value [value] at that position.
    - [arr]: The input 2D array.
    - Returns: A new 2D array with the results of applying [f] to each element.
    *)

    val copy : 'a t -> 'a t
end

type pixel = {
  r:int;
  g:int;
  b:int
  }
(** Type alias for an pixel representation as a tuple of ints. *)

type image = pixel Array_2d.t
(** Type alias for an image representation as a 2D array of pixels (tuples). *)

type energy_map = float Array_2d.t
(** Type alias for an energy map representation as a 2D array of floats. *)

module Minimal_energy_map :
sig
    type t = Pair.t Array_2d.t
    (** A minimal energy map type, represented as a 2D array of [Pair] cells. *)

    val from_energy_map : energy_map -> t
    (** [from_energy_map energy_map] converts a standard energy map (float Array_2d) to a minimal energy map (Pair Array_2d). *)

    val get_minimal_energy : t -> int -> int
    (** [get_minimal_energy map row] retrieves the column index of the minimum energy in the given row.
        - [map]: The minimal energy map.
        - [row]: The row to search in.
        - Returns: The column index with the minimum energy. *)

    val update_direction : t -> int -> int -> int -> unit
    (** [update_direction map row col direction] updates the direction value in a specified cell of the minimal energy map.
        - [map]: The minimal energy map.
        - [row], [col]: The row and column of the cell to update.
        - [direction]: The new direction value. *)

    val to_energy_map : t -> energy_map
    (** [to_energy_map map] converts a minimal energy map back to a standard energy map (float Array_2d). *)

    val iteri_bottom_to_top : t -> f:(int -> int -> Pair.t -> Pair.t) -> t
    (** [iteri_bottom_to_top map ~f] iterates over the minimal energy map starting from the bottom row up to the top row,
        and from left to right within each row. For each element, it calls [f ~row ~col pair].
        - [map]: The minimal energy map.
        - [f]: A function receiving ~row, ~col, and the [Pair.t] at that position. *)
end

  