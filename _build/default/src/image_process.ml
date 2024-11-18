open Types

module ImageProcess = struct
  let load_image (_filename : string) : image =
    failwith "Not implemented: load_image"

  let save_frame (_img : image) (_index : int) : unit =
    failwith "Not implemented: save_frame"

  let calculate_energy_map (_img : image) : energy_map =
    failwith "Not implemented: calculate_energy_map"

  let draw_seam (_img : image) (_seam : int array) : image =
    failwith "Not implemented: draw_seam"

  let copy_image (_img : image) : image =
    failwith "Not implemented: copy_image"
end

