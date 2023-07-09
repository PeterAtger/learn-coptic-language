#!/bin/bash

# Initialize a counter for renaming the files
counter=0

# Iterate over each file
for file in [0-9]*.png; do
    # Check if the file is not already named correctly
    if [[ $file != "${counter}.png" ]]; then
        # Rename the file
        mv "$file" "${counter}.png"
    fi
    
    # Increment the counter
    counter=$((counter + 1))
done
