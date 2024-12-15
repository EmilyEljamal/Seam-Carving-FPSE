document.addEventListener("DOMContentLoaded", () => {
  const dropArea = document.getElementById("drop-area");
  const fileInput = document.getElementById("file-input");
  const fileButton = document.getElementById("file-button");

  if (!dropArea || !fileInput || !fileButton) {
    console.error("Required DOM elements are missing.");
    return;
  }

  // Highlight drag area when a file is dragged over
  dropArea.addEventListener("dragover", (event) => {
    event.preventDefault();
    dropArea.classList.add("highlight");
  });

  // Remove highlight when drag leaves the area
  dropArea.addEventListener("dragleave", () => {
    dropArea.classList.remove("highlight");
  });

  // Handle file drop
  dropArea.addEventListener("drop", (event) => {
    event.preventDefault();
    dropArea.classList.remove("highlight");

    const file = event.dataTransfer.files[0];
    if (file) {
      console.log("File dropped:", file);
      processFile(file);
    }
  });

  // Trigger file input when button is clicked
  fileButton.addEventListener("click", () => {
    fileInput.click();
  });

  // Handle file selection through the input element
  fileInput.addEventListener("change", () => {
    const file = fileInput.files[0];
    if (file) {
      console.log("File selected:", file);
      processFile(file);
    }
  });

  // Function to handle file processing and upload
  function processFile(file) {
    console.log("Processing file:", file);

    const formData = new FormData();
    formData.append("image", file); // Append the file with key "image"
    formData.append("num_seams", "10"); // Example: append a hardcoded number of seams

    fetch("/upload", {
      method: "POST",
      body: formData,
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Failed to upload file. Status: ${response.status}`);
        }
        return response.text();
      })
      .then((data) => {
        console.log("Response from server:", data);

        // If a processed file is returned, update the UI
        const processedImage = document.getElementById("processed-image");
        const downloadLink = document.getElementById("download-link");

        if (processedImage && downloadLink) {
          processedImage.src = "/static/processed.gif"; // Update the image preview
          downloadLink.href = "/static/processed.gif"; // Update the download link
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
});
