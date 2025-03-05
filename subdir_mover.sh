#!/bin/bash

#################################
# Author:       Matej Ciglenečki
# Description:  script which moves files to subdirectories
#################################


# Directory containing your flat file collection
images_dir="./images"

# Number of files per subdirectory
# good number: sqrt(num_files_in_dir) # ls -1 | wc -l

num_files_in_dir=1000

# Additional file extensions to move along with the base image
# additional_extensions=("txt" "json")
additional_extensions=()

# Counters for the number of files processed and current subdirectory index
counter=0
subdir_index=0
base_ext="webp"

# Create the first subdirectory
mkdir -p "$images_dir/$subdir_index"

# Process each base image file
find "$images_dir" -maxdepth 1 -type f -name "*.$base_ext" | sort | while read -r file; do

    # Get the base name (without extension)
    base="${file%.$base_ext}"
    
    # Check if the base image file exists (this check is now redundant given find, but kept for consistency)
    if [[ -f "$base.$base_ext" ]]; then
        # If we've reached the limit for the current subdirectory, move to the next one
        if (( counter > 0 && counter % num_files_in_dir == 0 )); then
            subdir_index=$((subdir_index + 1))
            mkdir -p "$images_dir/$subdir_index"
        fi

        # Move the base image file
        mv "$base.$base_ext" "$images_dir/$subdir_index/"

        # Loop through each additional extension and move the corresponding file if it exists
        for ext in "${additional_extensions[@]}"; do
            if [[ -f "$base.$ext" ]]; then
                mv "$base.$ext" "$images_dir/$subdir_index/"
            fi
        done

        # Increment the counter for each base file processed
        counter=$((counter + 1))
    else
        echo "Warning: Missing base file for '$base'" >&2
    fi
done
