[@@@ocaml.warning "-27"]
open Core

module Pair = struct
  type t = {
    energy : float;
    direction : int;
  } [@@deriving compare]

  let create (_energy : float) (_direction : int) : t =
    { energy = _energy; direction = _direction }

  let get_energy (_pair : t) : float =
    _pair.energy

  let get_direction (_pair : t) : int =
    _pair.direction

  let update_energy (_pair : t) (_energy : float) : t =
    { energy = _energy; direction = _pair.direction }
end

module Array_2d = struct
  type 'a t = 'a array array

  let init (rows : int) (cols : int) (f : int -> int -> 'a) : 'a t =
    Array.init rows (fun i -> Array.init cols (fun j -> f i j))

  let get (arr : 'a t) (x : int) (y : int) : 'a option=
    Option.try_with (fun () -> arr.(x).(y))

  let dimensions (arr : 'a t) : int * int =
    (Array.length arr.(0), Array.length arr)

  let adjacents (arr : 'a t) (x : int) (y : int) : 'a list =
    let g xo yo = get arr (x + xo) (y + yo) in
    List.filter_map ~f:Fn.id
      [
       g 0 (-1); g (-1) 0; g 1 0; g 0 1;
      ]

  let map (f : int -> int -> 'a -> 'b) (arr : 'a t) : 'b t =
    Array.mapi arr ~f:(fun y r -> Array.mapi r ~f:(f y))

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