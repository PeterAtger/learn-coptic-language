#!/bin/bash

# Get a list of folders in the current directory
folders=$(find . -type d -name "*[0-9]*")

# Initialize a counter for renaming the files
counter=1

# Iterate over each folder
for folder in $folders; do
    # Find the PNG file in the folder
    file=$(find "$folder" -maxdepth 1 -type f -iname "*.png")

    # Check if a PNG file exists in the folder
    if [[ -n $file ]]; then
        # Rename the PNG file and move it to the root folder
        mv "$file" "${counter-1}.png"
        
        # Increment the counter
        counter=$((counter + 1))
    fi
done