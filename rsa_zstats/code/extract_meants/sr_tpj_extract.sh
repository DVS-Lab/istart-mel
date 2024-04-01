#!/usr/bin/env bash

# Ensure paths are correct irrespective from where user runs the script
source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/"
dest_dir="/ZPOOL/data/projects/istart-mel/data/sharedreward/tpj_sharedreward"

# Iterate through each subject folder in the source directory
for sub_dir in "${source_dir}/sharedreward/"sub-*; do
    sub=$(basename "$sub_dir")
    echo "${sub} pulled successfully"
    
    # Define mask path
    mask="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks/seed-pTPJ-bin.nii"

    # Define input files for fslmeants command using find
    input_files=$(find "${sub_dir}" -name '*.nii.gz' -type f)
    echo "Pulled inputs: ${input_files}"

    # Run fslmeants command with the mask for each zstat file
    for file in $input_files; do
        echo "${file} is being run"
        # Extracting the number from the file name
        number=$(basename "$file" | grep -oP '^\d+')
        # Renaming the file and moving it to the destination directory
        cp "$file" "${dest_dir}/${sub}_sharedreward_zstat${number}.nii.gz"
        # Running fslmeants command with the renamed file
        fslmeants -i "${dest_dir}/${sub}_sharedreward_zstat${number}.nii.gz" \
                  -m "${mask}" \
                  -o "${dest_dir}/${sub}_tpj_sharedreward_zstat${number}.txt"
        echo "Created successfully ${number}"
    done
done