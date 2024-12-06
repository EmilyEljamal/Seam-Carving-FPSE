[@@@ocaml.warning "-27"]
open Core

module Pair = struct
  type t = {
    energy : float;
    direction : int;
  } [@@deriving compare]

  let create ~in_energy ~in_direction : t =
    { energy = in_energy; direction = in_direction }

  let get_energy (_pair : t) : float =
    _pair.energy

  let get_direction (_pair : t) : int =
    _pair.direction

  let update_energy (_pair : t) (_energy : float) : t =
    { energy = _energy; direction = _pair.direction }
end

module Array_2d = struct
  type 'a t = 'a array array

  let init ~rows ~cols (f : int -> int -> 'a) : 'a t =
    Array.init rows ~f:(fun i -> Array.init cols ~f:(fun j -> f i j))

  let get ~arr ~row ~col : 'a option=
    Option.try_with (fun () -> arr.(row).(col))

    let get_row (arr : 'a t) (x : int) : 'a array option =
    Option.try_with (fun () -> arr.(x))

  let dimensions (arr: 'a array) : int * int =
    (Array.length arr.(0), Array.length arr)

  let adjacents ~arr ~row ~col : 'a list =
    let g xo yo = get ~arr ~row:(row + xo) ~col:(col + yo) in
    List.filter_map ~f:Fn.id
      [
       g 0 (-1); g (-1) 0; g 1 0; g 0 1;
      ]

  let map (f : int -> int -> 'a -> 'b) (arr : 'a t) : 'b t =
    Array.mapi arr ~f:(fun y r -> Array.mapi r ~f:(f y))

end

type pixel = int * int * int

type image = pixel Array_2d.t

type energy_map = float Array_2d.t

module Minimal_energy_map = struct
  type t = Pair.t Array_2d.t

  let from_energy_map (_energy_map : energy_map) : t =
    Array_2d.map (fun row col energy -> Pair.create ~in_energy:energy ~in_direction:0) _energy_map

  let get_minimal_energy (_map : t) (_row : int) : int =
    match Array_2d.get_row _map _row with
    | None -> failwith "Invalid row index"
    | Some row ->
        Array.foldi row ~init:(0, Float.infinity) ~f:(fun col_idx (min_idx, min_val) pair ->
            let energy = Pair.get_energy pair in
            if (Float.compare energy min_val < 0) then (col_idx, energy) else (min_idx, min_val))
        |> fst

  let update_direction (_map : t) (_row : int) (_col : int) (_direction : int) : unit =
    match Array_2d.get ~arr:_map ~row:_row ~col:_col with
    | None -> failwith "Invalid row index"
    | Some pair ->
      let updated_pair = Pair.create ~in_energy:(Pair.get_energy pair) ~in_direction:_direction in
      _map.(_row).(_col) <- updated_pair

  let to_energy_map (_map : t) : energy_map =
    Array_2d.map (fun row col pair -> Pair.get_energy pair) _map
end