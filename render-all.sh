#!/bin/bash

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Check if the provided directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' does not exist"
    exit 1
fi

# Change to the specified directory
cd "$1"

# Loop through all subdirectories
for subdir in */; do
    # Remove trailing slash
    dir=${subdir%/}
    
    # Check if .quarto.yml exists in the subdirectory
    if [ -f "$dir/_quarto.yml" ]; then
        echo "Rendering $dir (found .quarto.yml)"
        
        # Enter the subdirectory
        cd "$dir"
        
        # Run quarto render
        quarto render
        
        # Go back to parent directory
        cd ..
    else
        echo "Skipping $dir (no .quarto.yml found)"
    fi
done

echo "All rendering jobs completed"