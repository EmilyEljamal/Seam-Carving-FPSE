# Seam-Carving-FPSE

The purpose of this project is to develop an intelligent image transformation tool that uses seam carving to resize images while preserving critical visual elements. Regular resizing tools tend to distort or lose important parts of an image whereas seam carving uses vertical and horizontal seams (paths of low importance pixels) that are either removed or inserted to maintain the integrity of key features. This makes it ideal for resizing images with complex details where certain areas should remain untouched despite a change in dimensions.

We will develop a seam carving algorithm in OCaml that will apply functional programming concepts. OCaml’s Core library will support functional abstractions and efficient data manipulation while OCamlImages will be used to handle the storage of images and handle the output of the final image product. 

The project will also include a dynamic visual component, where each intermediate step of the resizing process is saved as a frame to create a GIF or video of the resizing progression. We will be using **INSERT GIF MAKER** to complete this. This feature will provide users with an animated view of how the image adjusts as seams are removed or added, highlighting the algorithm’s ability to maintain the visual integrity of the image’s important features.

Overall, this project serves as a deep dive into algorithmic image processing, emphasizing efficient memory management, data persistence, and functional problem-solving in OCaml. The result will be a tool that enables intelligent image resizing and serves as a foundational piece for more advanced applications in adaptive media and computer vision.
