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

  let get_row (arr : 'a t) (row : int) : 'a array option =
  Option.try_with (fun () -> arr.(row))

  let dimensions (arr: 'a array) : int * int =
    (Array.length arr, Array.length arr.(0))

  let set ~(arr: 'a t) ~row ~col value = arr.(row).(col) <- value
  (* OH: Calc_minimal_energy *)

  let adjacents ~arr ~row ~col : 'a list =
    let g xo yo = get ~arr ~row:(row + xo) ~col:(col + yo) in
    List.filter_map ~f:Fn.id
      [
       g 0 (-1); g 0 1; g (-1) 0; g 1 (0);
      ]

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
        Array.init cols ~f:(fun col ->
            arr.(row).(col)
        )
  )

  let bottom_neighbors ~arr ~row ~col : (int * 'a) list =
    let g dx dy dir =
      match get ~arr ~row:(row + dx) ~col:(col + dy) with
      | Some value -> Some (dir, value)
      | None -> None
    in
    List.filter_map ~f:Fun.id
      [
        g (1) (-1) (-1);  (* SW *)
        g (1) 0 0;        (* S  *)
        g (1) 1 1;        (* SE *)
      ]
end

type pixel = {
  r:int;
  g:int;
  b:int }

type image = pixel Array_2d.t

type energy_map = float Array_2d.t

module Minimal_energy_map = struct
  type t = Pair.t Array_2d.t

  let from_energy_map (energy_map : energy_map) : t =
    Array_2d.map (fun row col energy -> Pair.create ~in_energy:energy ~in_direction:0) energy_map

  let get_minimal_energy (map : t) (row : int) : int =
    match Array_2d.get_row map row with
    | None -> failwith "Invalid row index"
    | Some x ->
        Array.foldi x ~init:(0, Float.infinity) ~f:(fun col_idx (min_idx, min_val) pair ->
            let energy = Pair.get_energy pair in
            if (Float.compare energy min_val < 0) then (col_idx, energy) else (min_idx, min_val))
        |> fst

  let update_direction (map : t) (row : int) (col : int) (direction : int) : unit =
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

