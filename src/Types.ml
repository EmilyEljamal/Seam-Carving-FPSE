[@@@ocaml.warning "-27"]
open Core

(** Module for movement directions and related utilities *)
module Direction = struct
  (** Represents possible movement directions. *)
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

  (** [direction_to_offset direction] maps a direction to its row and column offsets. *)
  let direction_to_offset = function
    | Neutral    -> (0, 0)
    | North      -> (-1, 0)
    | South      -> (1, 0)
    | East       -> (0, 1)
    | West       -> (0, -1)
    | NorthWest  -> (-1, -1)
    | NorthEast  -> (-1, 1)
    | SouthWest  -> (1, -1)
    | SouthEast  -> (1, 1)

  (** [horizontal_offset direction] extracts the horizontal movement (-1, 0, 1) for a direction. *)
  let horizontal_offset direction =
    let _, dy = direction_to_offset direction in
    dy

  (** [next_col ~col ~direction] calculates the next column index based on the direction. *)
  let next_col ~col ~direction =
    col + horizontal_offset direction

end

type direction = Direction.t

type pixel = {
  r:int;
  g:int;
  b:int }


  module Energy = struct
    (** The type representing a single energy value. *)
    include Direction
    type t = float
    
  
    (** [create value] creates an energy value. *)
    let create value : t = value
  
    (** [value energy] extracts the float value of energy. *)
    let value (energy : t) : float = energy
  
    (** [calculate_pixel_energy ~neighbors] computes the energy from pixel neighbors. *)
    let calculate_pixel_energy ~neighbors : t =
      let get_rgb_diff n1 n2 =
        let dx_r = n2.r - n1.r in
        let dx_g = n2.g - n1.g in
        let dx_b = n2.b - n1.b in
        (dx_r * dx_r) + (dx_g * dx_g) + (dx_b * dx_b)
      in
    
      let find_neighbor dir =
        List.Assoc.find neighbors dir ~equal:Poly.equal
        |> Option.value ~default:{ r = 0; g = 0; b = 0 }
      in
    
      let west  = find_neighbor West in
      let east  = find_neighbor East in
      let north = find_neighbor North in
      let south = find_neighbor South in
    
      let dx2 = get_rgb_diff west east in
      let dy2 = get_rgb_diff north south in
      Float.of_int (dx2 + dy2)
  end

  

  module Pair = struct
    type t = {
      energy : float;
      direction : Direction.t; 
    } [@@deriving compare]
  
    let create ~in_energy ~in_direction : t =
      { energy = in_energy; direction = in_direction }
  
    let get_energy (_pair : t) : float =
      _pair.energy
  
    let get_direction (_pair : t) : Direction.t =
      _pair.direction
  
    let update_energy (_pair : t) (_energy : float) : t =
      { energy = _energy; direction = _pair.direction }
  end
  


module Array_2d = struct
  type 'a t = 'a array array

  let init ~rows ~cols (f : int -> int -> 'a) : 'a t =
    Array.init rows ~f:(fun i -> Array.init cols ~f:(fun j -> f i j))

  let get ~arr ~row ~col : 'a option =
    Option.try_with (fun () -> arr.(row).(col))

  let get_row (arr : 'a t) (row : int) : 'a array option =
    Option.try_with (fun () -> arr.(row))

  let dimensions (arr : 'a t) : int * int =
    (Array.length arr, Array.length arr.(0))

  let set ~(arr: 'a t) ~row ~col value = arr.(row).(col) <- value

  let map (f : int -> int -> 'a -> 'b) (arr : 'a t) : 'b t =
    Array.mapi arr ~f:(fun y r -> Array.mapi r ~f:(f y))

  let mapi (f : int -> int -> 'a -> 'b) (arr : 'a t) : 'b t =
    Array.mapi ~f:(fun row row_array ->
      Array.mapi ~f:(fun col value -> f row col value) row_array
    ) arr

  let copy (arr: 'a t) : 'a t =
    let rows = Array.length arr in
    let cols = if rows > 0 then Array.length arr.(0) else 0 in
    Array.init rows ~f:(fun row ->
        Array.init cols ~f:(fun col -> arr.(row).(col))
    )

  let neighbors ~arr ~row ~col ~directions : (direction * 'a) list =
    List.filter_map directions ~f:(fun dir ->
      let dx, dy = Direction.direction_to_offset dir in
      match get ~arr ~row:(row + dx) ~col:(col + dy) with
      | Some value -> Some (dir, value)
      | None -> None
    )

  let bottom_neighbors ~arr ~row ~col : (direction * 'a) list =
    neighbors ~arr ~row ~col ~directions:[SouthWest; South; SouthEast]

  let adjacents ~arr ~row ~col : (direction * 'a) list =
    neighbors ~arr ~row ~col ~directions:[North; South; East; West]
end

type image = pixel Array_2d.t



type energy_map = Energy.t Array_2d.t


module Minimal_energy_map = struct
  type t = Pair.t Array_2d.t

  let from_energy_map (energy_map : float Array_2d.t) : t =
    Array_2d.map (fun _ _ energy -> Pair.create ~in_energy:energy ~in_direction:Neutral) energy_map
  

  let get_minimal_energy (map : t) (row : int) : int =
    match Array_2d.get_row map row with
    | None -> failwith "Invalid row index"
    | Some x ->
        Array.foldi x ~init:(0, Float.infinity) ~f:(fun col_idx (min_idx, min_val) pair ->
            let energy = Pair.get_energy pair in
            if (Float.compare energy min_val < 0) then (col_idx, energy) else (min_idx, min_val))
        |> fst

  let update_direction (map : t) (row : int) (col : int) (direction : direction) : unit =
    match Array_2d.get ~arr:map ~row:row ~col:col with
    | None -> failwith "Invalid row index"
    | Some pair ->
      let updated_pair = Pair.create ~in_energy:(Pair.get_energy pair) ~in_direction:direction in
      map.(row).(col) <- updated_pair

  let to_energy_map (map : t) : energy_map =
    Array_2d.map (fun row col pair -> Pair.get_energy pair) map
    
  let iteri_bottom_to_top (arr : t) ~(f : int -> int -> Pair.t -> Pair.t) : t =
    let rows = Array.length arr in
    let cols = if rows > 0 then Array.length arr.(0) else 0 in
    Array.init rows ~f:(fun row ->
      Array.init cols ~f:(fun col ->
        let original_row = rows - 1 - row in
        f original_row col arr.(original_row).(col)
      )
    )
    
    
  
end