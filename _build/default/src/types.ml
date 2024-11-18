[@@@ocaml.warning "-27"]

module Pair = struct
  type t = {
    energy : float;
    direction : int;
  } [@@deriving compare]

  let create (_energy : float) (_direction : int) : t =
    failwith "Not implemented: Pair.create"

  let get_energy (_pair : t) : float =
    failwith "Not implemented: Pair.get_energy"

  let get_direction (_pair : t) : int =
    failwith "Not implemented: Pair.get_direction"

  let update_energy (_pair : t) (_energy : float) : t =
    failwith "Not implemented: Pair.update_energy"
end

module Array_2d = struct
  type 'a t = 'a array array

  let init (rows : int) (cols : int) (f : int -> int -> 'a) : 'a t =
    failwith "Not implemented: Array_2d.init"

  let get (arr : 'a t) (x : int) (y : int) : 'a =
    failwith "Not implemented: Array_2d.get"

  let dimensions (arr : 'a t) : int * int =
    failwith "Not implemented: Array_2d.dimensions"

  let adjacents (arr : 'a t) (x : int) (y : int) : 'a list =
    failwith "Not implemented: Array_2d.adjacents"

  let map (f : 'a -> 'b) (arr : 'a t) : 'b t =
    failwith "Not implemented: Array_2d.map"
end

type image = float Array_2d.t

type energy_map = float Array_2d.t

module Minimal_energy_map = struct
  type t = Pair.t Array_2d.t

  let from_energy_map (_energy_map : energy_map) : t =
    failwith "Not implemented: Minimal_energy_map.from_energy_map"

  let get_minimal_energy (_map : t) (_row : int) : int =
    failwith "Not implemented: Minimal_energy_map.get_minimal_energy"

  let update_direction (_map : t) (_row : int) (_col : int) (_direction : int) : unit =
    failwith "Not implemented: Minimal_energy_map.update_direction"

  let to_energy_map (_map : t) : energy_map =
    failwith "Not implemented: Minimal_energy_map.to_energy_map"
end