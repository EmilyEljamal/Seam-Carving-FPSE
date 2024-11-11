type image = Array_2d

type energy_map = Array_2d

module Pair :
  sig
    type t =
      { energy : float
      ; direction   : int } [@@deriving compare]
  end

module Array_2d : 
sig 
    type 'a t = 'a array array
end

module Minimal_energy_map :
sig
    type t = Pair.t Array_2d.t
end