Project Design Proposal
Fall 2024
Professor Smith
Group: Emily Eljamal & Maria-Noelia Herne
Date: 11/13/2024

Github Link: https://github.com/EmilyEljamal/Seam-Carving-FPSE 

# Seam Carving to Resize Images

# Project Overview

The purpose of this project is to develop an image transformation tool that uses seam carving to resize images while preserving critical visual elements. Regular resizing tools tend to distort or lose important parts of an image whereas seam carving uses vertical seams (paths of low importance pixels) that are either removed or inserted to maintain the integrity of key features. This makes it ideal for resizing images with complex details where certain areas should remain untouched despite a change in dimensions.

We will develop a seam carving algorithm in OCaml that will apply functional programming concepts. OCaml’s Core library will support functional abstractions and efficient data manipulation while ImageMagick will be used to handle the storage of images and handle the output of the final image product.

The project will also include a dynamic visual component, where each intermediate step of the resizing process is saved as a frame to create a GIF or video of the resizing progression. We will be using ImageMagick to complete this. This feature will provide users with an animated view of how the image adjusts as seams are removed or added, highlighting the algorithm’s ability to maintain the visual integrity of the image’s important features.

Overall, this project serves as a deep dive into algorithmic image processing, emphasizing efficient memory management, data persistence, and functional problem-solving in OCaml. The result will be a tool that enables image resizing and serves as a foundational piece for more advanced applications in adaptive media and computer vision.

        			
# Algorithm Description
The algorithm we will use to implement Seam Carving is derived from the MIT lesson from Fall 2020 Seam Carving | Week 2, lecture 7 | 18.S191 MIT Fall 2020.
https://www.youtube.com/watch?v=rpB6zQNsbQU&t=230s
The main sequence of the algorithm is 
Create an Energy Grid of values 0-1 (black-white) to assign importance to pixels based on edge detection
Time Complexity: O(N)

Calculate the Minimal Energy to Bottom Grid using dynamic programming

- Time Complexity: O(3N) = O(N), where N is number of pixels
The goal is to build from the bottom row up the minimal total value of a cell to the bottom of the grid.
- 1st, copy the bottom row
- 2nd, traverse through each cell, bottom to top, left to right
- 3rd, for each cell, check adding cell value to each the diagonal bottom L neighbor, bottom, and diagonal bottom R neighbor and save the lowest value of the 3 and the corresponding direction (-1,0,1)
Using the prev grid, calculate from top to bottom, the path of least importance or the seam aka the vertical path of pixels that will be removed


# List of Libraries

- Core
- Sys_unix
- Stdio
- ImageMagick (Demo included)

## Implementation Plan

- [ ] **11/22: Types + Image Life Cycle**
  - [ ] Finalize Types
  - [ ] Implement `Image_Process.ml` (not including `calculate_energy_map`)
  - [ ] Set up `main.ml` for command-line interface
  - [ ] Test loading image, trivial pixel removal, and output

- [ ] **11/29: First Algorithm**
  - [ ] Implement `calculate_energy_map`
  - [ ] Test and visualize energy map

- [ ] **12/6: Second Algorithm**
  - [ ] Implement `Seam_identification.ml`
  - [ ] Test and visualize seam identification output
  - [ ] Test creating GIF from pixel removal snapshots

- [ ] **12/13: Testing**
  - [ ] Comprehensive testing and refinement of all modules

# Note about Project Complexity
https://pages.cs.wisc.edu/~moayad/cs766/index.html

If the project scope is small, then we would add a object removal/protection feature to the application as mentioned in the above link.
This means that similar to photoshop's object removal from a photo that recreates a background, a complex application of seam carving
should accomplish this. We would also build then a front-end website with a drag-drop feature to load images, a slider to realtime-condense or expand images sizes using seam carving.
