#!/bin/bash

# Base directory containing subject folders
BASE_DIR="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl"

# Loop through each subject folder
for SUB_DIR in ${BASE_DIR}/sub-*; do
    if [ -d "$SUB_DIR" ]; then
        echo "Processing $SUB_DIR"

        # Find and delete 'doors' or 'socialdoors' feat folders
        find "$SUB_DIR" -type d \( -name "*task-doors*.feat" -o -name "*task-socialdoors*.feat" \) -exec rm -rf {} +
        
        # Find and delete 'doors' or 'socialdoors' fsf files
        find "$SUB_DIR" -type f \( -name "*task-doors*.fsf" -o -name "*task-socialdoors*.fsf" \) -exec rm -f {} +

        echo "Deleted doors and socialdoors feat folders and fsf files in $SUB_DIR (if any)."
    else
        echo "Skipping $SUB_DIR (not a directory)."
    fi
done

echo "Cleanup complete!"