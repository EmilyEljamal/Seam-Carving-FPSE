  (* server.ml
  open Dream
  open Core
  open Lwt.Syntax
  
  (* Handler to process uploaded files and seam count *)
  let upload_handler request =
    let%lwt result = Dream.multipart request in
    match result with
    | `Ok parts -> (
        (* Extract the "image" field. We expect a single uploaded file. *)
        let file_content =
          List.find_map parts ~f:(fun (key, values) ->
            if String.equal key "image" then
              match values with
              | [(Some _filename, data)] -> Some data
              | [(None, data)] -> Some data
              | _ -> None
            else
              None)        
        in
  
        (* Extract the "num_seams" field. We expect a text field. *)
        let num_seams_str =
          List.find_map parts ~f:(fun (key, values) ->
            if String.equal key "num_seams" then
              match values with
              | [(None, seam_count_str)] -> Some seam_count_str
              | _ -> None
            else
              None)
        in
  
        (* Check if both file and seam count were provided. *)
        match file_content, num_seams_str with
        | Some fc, Some ns -> (
            try
              let num_seams = int_of_string ns in
              let output_path = "static/processed.gif" in
  
              (* Process the image with the provided seam count. *)
              Processing.process_image ~input_path:fc ~num_seams ~output_path;
  
              (* Send the file as a response. *)
              let%lwt response = Dream.respond ~headers:[
                ("Content-Type", "image/gif");
                ("Content-Disposition", "inline; filename=processed.gif")
              ] (Dream.read_file output_path) in
              Lwt.return response
            with
            | Failure _ -> Dream.respond ~status:`Bad_Request "Invalid seam count.")
        | _ ->
            Dream.respond ~status:`Bad_Request
              "Invalid request. Please upload an image and specify the number of seams.")
    | _ ->
        Dream.respond ~status:`Bad_Request "Invalid multipart data."
  
  (* Main function to run the server *)
  let () =
    Dream.run
    @@ Dream.logger
    @@ Dream.router [
      Dream.post "/upload" upload_handler;
    ]
   (* *)
  

open Dream *)
open Core
(* open Lwt.Syntax

let upload_handler request =
  match%lwt Dream.multipart request with
  | `Ok parts ->
      (* Extract the "image" field. We expect a single uploaded file. *)
      let file_content =
        List.find_map parts ~f:(fun (key, values) ->
          if String.equal key "image" then
            match values with
            | [(Some _filename, data)] -> Some data
            | [(None, data)] -> Some data
            | _ -> None
          else None)
      in

      (* Extract the "num_seams" field. We expect a text field. *)
      let num_seams_str =
        List.find_map parts ~f:(fun (key, values) ->
          if String.equal key "num_seams" then
            match values with
            | [(None, seam_count_str)] -> Some seam_count_str
            | _ -> None
          else None)
      in

      (match file_content, num_seams_str with
       | Some fc, Some ns ->
           let num_seams = int_of_string ns in
           let output_path = "static/processed.gif" in
           (* Process the image with the provided seam count. *)
           Processing.process_image ~input_path:fc ~num_seams ~output_path;

           (* Read the processed file using Lwt_io and respond. *)
           let%lwt file_content = Lwt_io.(with_file ~mode:Input output_path read) in
           Dream.respond
             ~headers:["Content-Disposition", "inline; filename=processed.gif"]
             file_content

       | _ ->
           Dream.respond ~status:`Bad_Request
             "Invalid request. Please upload an image and specify the number of seams.")
  | _ ->
      Dream.respond ~status:`Bad_Request "Invalid multipart data." *)
(* 
let home_handler _request =
  Dream.html "<h1>Welcome to My Website!</h1><p>This is a simple Dream application.</p>" *)
  (* let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ ->
      match Sys_unix.file_exists "./static/index.html" with
      | `Yes ->
          let%lwt file_content = Lwt_io.(with_file ~mode:Input "./static/index.html" read) in
          Dream.html file_content
      | `No | `Unknown ->
          Dream.respond ~status:`Internal_Server_Error "index.html not found");

    Dream.get "/static/**" (Dream.static "./static");

    Dream.post "/upload" upload_handler;
  ] *)

  let upload_handler request =
    Dream.log "Upload endpoint hit";
    match%lwt Dream.multipart request with
    | `Ok parts ->
        Dream.log "Received multipart data";
  
        (* Extract the "image" field. We expect a single uploaded file. *)
        let file_content =
          List.find_map parts ~f:(fun (key, values) ->
            Printf.printf "Processing key: %s\n%!" key;
            if String.equal key "image" then
              match values with
              | [(Some _filename, data)] -> 
                  Printf.printf "Image file found\n%!";
                  Some data
              | [(None, data)] -> 
                  Printf.printf "Anonymous file found\n%!";
                  Some data
              | _ -> 
                  Printf.printf "No valid file data found\n%!";
                  None
            else None)
        in
  
        (* Extract the "num_seams" field. We expect a text field. *)
        let num_seams_str =
          List.find_map parts ~f:(fun (key, values) ->
            Printf.printf "Processing key: %s\n%!" key;
            if String.equal key "num_seams" then
              match values with
              | [(None, seam_count_str)] -> 
                  Printf.printf "Seam count found: %s\n%!" seam_count_str;
                  Some seam_count_str
              | _ -> 
                  Printf.printf "No valid seam count found\n%!";
                  None
            else None)
        in
  
        (match file_content, num_seams_str with
         | Some fc, Some ns ->
             Printf.printf "File and num_seams received. Num_seams: %s\n%!" ns;
             let num_seams = int_of_string ns in
             let output_path = "static/processed.gif" in
             (* Process the image with the provided seam count. *)
             Printf.printf "Processing image with %d seams\n%!" num_seams;
             Processing.process_image ~input_path:fc ~num_seams ~output_path;
  
             (* Read the processed file using Lwt_io and respond. *)
             let%lwt file_content = Lwt_io.(with_file ~mode:Input output_path read) in
             Printf.printf "Image processing complete. Returning response.\n%!";
             Dream.respond
               ~headers:["Content-Disposition", "inline; filename=processed.gif"]
               file_content
  
         | _ ->
             Printf.printf "Invalid request: Missing file or num_seams\n%!";
             Dream.respond ~status:`Bad_Request
               "Invalid request. Please upload an image and specify the number of seams.")
    | _ ->
        Printf.printf "Invalid multipart data\n%!";
        Dream.respond ~status:`Bad_Request "Invalid multipart data."
  
  (* Uncomment and debug home_handler if needed *)
  (* let home_handler _request =
    Dream.html "<h1>Welcome to My Website!</h1><p>This is a simple Dream application.</p>" *)
  
  let () =
    Dream.run
    @@ Dream.logger
    @@ Dream.router [
      Dream.get "/" (fun _ ->
        match Sys_unix.file_exists "./static/index.html" with
        | `Yes ->
            Printf.printf "index.html exists. Reading file.\n%!";
            let%lwt file_content = Lwt_io.(with_file ~mode:Input "./static/index.html" read) in
            Printf.printf "index.html read successfully. Returning content.\n%!";
            Dream.html file_content
        | `No | `Unknown ->
            Printf.printf "index.html not found or unknown state\n%!";
            Dream.respond ~status:`Internal_Server_Error "index.html not found");
  
      Dream.get "/static/**" (Dream.static "./static");
      Dream.post "/upload" upload_handler;
    ]
  