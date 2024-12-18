(** Module representing orientations for seam removal *)
module Orientation : sig
  type orientation =
    | Vertical
    | Horizontal
end


(** Represents possible access points for a pixel neighbor *)
module Direction : sig
  (** Represents possible access points for a pixel neighbor, in a 3x3 grid format with the og pixel considered as "Neutral" *)
  type t =
    | Neutral
    | North
    | South
    | East
    | West
    | NorthWest
    | NorthEast
    | SouthWest
    | SouthEast

  (** [direction_to_offset direction] maps a direction to its row and column offsets to be used in accessing array element.
      - Returns a pair [(dx, dy)]
   *)
  val direction_to_offset : t -> int * int

  (** [horizontal_offset direction] extracts the horizontal movement for a given direction.
      - Returns [-1], [0], or [1] for left, no movement, or right.
   *)
  val horizontal_offset : t -> int

  (** [next_col ~col ~direction] calculates the next column index based on the direction.
      - Returns the updated column index. Calls horizontal_offset within
   *)
  val next_col : col:int -> direction:t -> int
end
type direction = Direction.t

(** A pixel with RGB values. *)
type pixel = { r : int; g : int; b : int }

(** Module to handle energy values. Used within Energy map
Overall: Image -> Energy Map -> Minimal Energy Map *)
module Energy : sig
  (** The type representing a single energy value. *)
  type t = float

  (** [calculate_pixel_energy ~neighbors] calculates the energy for a pixel based on its neighbors. *)
  val calculate_pixel_energy : neighbors:(direction * pixel) list -> t
end


module Pair : sig
  (** The type representing a pair of energy and direction. *)
  type t =
      { energy : float
      ; direction   : direction} [@@deriving compare]

  (** [create ~in_energy ~in_direction] creates a pair with energy and direction. *)
  val create : in_energy:float -> in_direction:direction -> t

  (** [get_energy pair] retrieves the energy value from the pair. *)
  val get_energy : t -> float

  (** [get_direction pair] retrieves the direction from the pair. *)
  val get_direction : t -> direction

  (** [update_energy pair energy] updates the energy of a pair. *)
  val update_energy : t -> float -> t
end

module Array_2d : sig
  (** The type representing a 2D generalized array. *)
  type 'a t = 'a array array

  (** [init ~rows ~cols f] initializes a 2D array using function [f]. *)
  val init : rows:int -> cols:int -> (int -> int -> 'a) -> 'a t

  (** [get ~arr ~row ~col] retrieves the value at [(row, col)] safely. *)
  val get : arr:'a t -> row:int -> col:int -> 'a option

  (** [get_row arr row] retrieves a row from the 2D array safely. *)
  val get_row : 'a t -> int -> 'a array option

  (** [dimensions arr] returns the dimensions of the 2D array. *)
  val dimensions : 'a t -> int * int

  (** [set ~arr ~row ~col value] sets the value at [(row, col)] in the array. Note: Mutation *)
  val set : arr:'a t -> row:int -> col:int -> 'a -> unit

  (** [map f arr] maps a function [f] over the array. *)
  val map : (int -> int -> 'a -> 'b) -> 'a t -> 'b t

  (** [mapi f arr] maps a function [f] with indices over the array. *)
  val mapi : (int -> int -> 'a -> 'b) -> 'a t -> 'b t

  (** [copy arr] creates a deep copy of the array. *)
  val copy : 'a t -> 'a t

  (** [neighbors ~arr ~row ~col ~directions] retrieves neighbors of a cell in specified directions which is in a provided list. *)
  val neighbors : arr:'a t -> row:int -> col:int -> directions:direction list -> (direction * 'a) list

  (** [bottom_neighbors ~arr ~row ~col] retrieves the bottom neighbors of a cell. *)
  val bottom_neighbors : arr:'a t -> row:int -> col:int -> (direction * 'a) list


  (** [transpose arr] transposes the 2D array [arr], swapping rows and columns. *)
  val transpose : 'a t -> 'a t
end

(** An image represented as a 2D array of pixels. *)
type image = pixel Array_2d.t

(** An energy map represented as a 2D array of energy values. *)
type energy_map = Energy.t Array_2d.t


module Minimal_energy_map : sig
  (** The type representing a minimal energy map as a 2D array of Pairs. *)
  type t = Pair.t Array_2d.t

  (** [from_energy_map energy_map] converts an energy map into a minimal energy map. *)
  val from_energy_map : energy_map -> t

  (** [get_minimal_energy map row] finds the column index with minimal energy in the given row. *)
  val get_minimal_energy : t -> int -> int

  (** [update_direction map row col direction] updates the direction of a cell. *)
  val update_direction : t -> int -> int -> direction -> unit

  (** [to_energy_map map] converts a minimal energy map back to an energy map. *)
  val to_energy_map : t -> energy_map

  (** [map_bottom_to_top arr ~f] maps over the array from bottom to top, applying function [f]. *)
  val map_bottom_to_top : t -> f:(int -> int -> Pair.t -> Pair.t) -> t
end