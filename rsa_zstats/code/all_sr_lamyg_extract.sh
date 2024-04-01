#!/usr/bin/env bash

# FUNKY MASK??? double check.. should be ok though

# Ensure paths are correct irrespective from where user runs the script
source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward"
dest_dir="/ZPOOL/data/projects/istart-mel/data/sharedreward/lamyg_sharedreward"

# Iterate through each subject folder in the source directory
for sub_dir in "${source_dir}/"sub-*; do
    sub=$(basename "$sub_dir")
    echo "${sub} pulled successfully"
    
    # Extract the subject number from the directory name
    sub_number=$(echo "$sub" | grep -oE '[0-9]+')

    # Define mask path
    mask="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks/rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz"

    # Define input files for fslmeants command using find
    input_files=$(find "${sub_dir}" -name '*.nii.gz' -type f)
    echo "Pulled inputs: ${input_files}"

    # Run fslmeants command with the mask for each zstat file
    for file in $input_files; do
        echo "${file} is being run"
        # Extracting the number from the directory name
        number=$(basename "$file" | grep -oE '[0-9]+')
        # Renaming the file and moving it to the destination directory
        cp "$file" "${dest_dir}/${sub}_sr_zstat${number}.nii.gz"
        # Running fslmeants command with the renamed file
        fslmeants -i "${dest_dir}/${sub}_sr_zstat${number}.nii.gz" \
                  -m "${mask}" --showall \
                  -o "${dest_dir}/${sub}_lamyg_sr_zstat${number}.csv"
        echo "Created successfully ${number}"
    done
done