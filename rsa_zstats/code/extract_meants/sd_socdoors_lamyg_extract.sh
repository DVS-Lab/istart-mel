#!/usr/bin/env bash

# Ensure paths are correct irrespective from where user runs the script
source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/socdoors"
dest_dir="/ZPOOL/data/projects/istart-mel/data/socialdoors/lamyg_socdoors"

# Iterate through each subject folder in the source directory
for sub_dir in "${source_dir}/socialdoors/"sub-*; do
    sub=$(basename "$sub_dir")
    echo "${sub} pulled successfully"
    
    # Define mask path
    mask="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks/rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz"

    # Define input files for fslmeants command using find
    input_files=$(find "${sub_dir}" -name '*.nii.gz' -type f)
    echo "Pulled inputs: ${input_files}"

    # Run fslmeants command with the mask for each zstat file
    for file in $input_files; do
        echo "${file} is being run"
        # Extracting the number from the file name
        number=$(basename "$file" | grep -oP '^\d+')
        # Copy and renaming the file and moving it to the destination directory to be run thru fslmeants
        cp "$file" "${dest_dir}/${sub}_socdoors_zstat${number}.nii.gz"
        # Running fslmeants command with the renamed file
        fslmeants -i "${dest_dir}/${sub}_socdoors_zstat${number}.nii.gz" \
                  -m "${mask}" \
                  -o "${dest_dir}/${sub}_lamyg_socdoors_zstat${number}.txt"
        echo "Created successfully ${number}"
    done
done