# Seam Carving to Resize Images - FPSE Fall '24
Authors: Emily Eljamal + Maria Herne


The purpose of this project is to develop an intelligent image transformation tool that uses seam carving to resize images while preserving critical visual elements. Regular resizing tools tend to distort or lose important parts of an image whereas seam carving uses vertical and horizontal seams (paths of low importance pixels) that are either removed or inserted to maintain the integrity of key features. This makes it ideal for resizing images with complex details where certain areas should remain untouched despite a change in dimensions.

We will develop a seam carving algorithm in OCaml that will apply functional programming concepts. OCaml’s Core library will support functional abstractions and efficient data manipulation while ImageMagick will be used to handle the storage of images and handle the output of the final image product. 

The project will also include a dynamic visual component, where each intermediate step of the resizing process is saved as a frame to create a GIF or video of the resizing progression. We will be using ImageMagick to complete this. This feature will provide users with an animated view of how the image adjusts as seams are removed or added, highlighting the algorithm’s ability to maintain the visual integrity of the image’s important features.

Overall, this project serves as a deep dive into algorithmic image processing, emphasizing efficient memory management, data persistence, and functional problem-solving in OCaml. The result will be a tool that enables intelligent image resizing and serves as a foundational piece for more advanced applications in adaptive media and computer vision.

## Sample Output

Below are some sample outputs of the program, showing both vertical and horizontal seam removal:

<img src="beach_output_30_seams_removed.png.gif" alt="Combined Seam GIF" width="300"/>


---

## How to Run the Program

### Prerequisites

Make sure you have the following tools installed:

- **OCaml** and **Dune** for building and running the program.
- **ImageMagick** (version 7+), which is used for processing images and generating GIFs.

> ⚠️ **WARNING**: In ImageMagick v7+, the `convert` command is deprecated. Use `magick convert` instead.  
> If you see the message:
> ```
> WARNING: The convert command is deprecated in IMv7, use "magick" instead of "convert" or "magick convert"
> ```
> This means the program is running correctly.

---

### Steps to Run

1. **Build the Project**  
   Run the following command to compile the project:
   ```bash
   dune build

2. **Build the Project**  
   Use the following command to execute the seam carving program:
   ```bash
    dune exec seam_carving -- <input_image> <num_seams> <output_image>
Example command using test.png within project folder :
```bash 
dune exec seam_carving -- test.png 10 beach_combined.gif 
```

 Note that this process may take some time as seam carving is computationally intensive. Please only use low resolution images and keep the seams removed under 50 or so. For a quick run, we recommend 10 seam removals. The average runtime for the test.png is 
```bash
    dune exec seam_carving -- test.png 50 beach_output1.png  

    185.00s user 6.21s system 93% cpu 3:24.09 total
```
References:

https://github.com/vivianhylee/seam-carving

https://pages.cs.wisc.edu/~moayad/cs766/index.html

## Code Checkpoint 12/6
At this time, we have completed types, image processing and parts of seam identification. Types contains all of the data structures that we will need for the actual completion of our algorithm such as a 2d array, pairs, pixels, images, energy maps, and minimal energy maps along with helper functions. In addition, we covered 100% of the testing for it. Image processing can successfully load an image from a path, convert it into a 2d array, change select pixels on an image to hot pink and sets up removing pixels from an image. In seam identification, we completed the main algorithm of calculating the minimal energy grid which forms a critical part of seam carving. Some of our code needs to be refactored and made simpler, however, it is all working as planned.

In the next 2 weeks before the project is due, we plan to continue to work on our command line in main (which has been started), finish calculate vertical seam and remove seam, and finally finish the gif module. When all of that is completed, we will most likely create a front end where users are able to input the command line options, paths and resizing parameters, and see the gif and output image on screen. If time allows, we may incorporate object removal functionality.
