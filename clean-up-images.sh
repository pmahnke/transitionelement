#!/bin/bash

IMAGE_DIR="assets/images"
OUTPUT_FILE="orphans.txt"

# Clear the output file if it already exists
> "$OUTPUT_FILE" 

echo "Hunting for orphaned images..."

find "$IMAGE_DIR" -type f | while read -r img_path; do
  filename=$(basename "$img_path")
  
  if ! grep -qR "$filename" _posts _pages _layouts _includes index.html 2>/dev/null; then
    # Write the exact path to our text file instead of deleting
    echo "$img_path" >> "$OUTPUT_FILE"
  fi
done

echo "Done! Target list saved to $OUTPUT_FILE"
