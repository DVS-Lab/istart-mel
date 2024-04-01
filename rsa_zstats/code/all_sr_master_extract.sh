#!/usr/bin/env bash

### mask options: 
#rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz
#rHarvardOxford_right-amygdala_nan_thr_bin.nii.gz
#seed-pTPJ-bin.nii
#seed-vmPFC-5mm-thr.nii
#seed-VS_thr5.nii.gz
roi="lamyg"
mask_loc="rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz"

# Ensure paths are correct irrespective from where user runs the script
source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward"
dest_dir="/ZPOOL/data/projects/istart-mel/data/sharedreward/${roi}_sharedreward"

# Iterate through each subject folder in the source directory
for sub_dir in "${source_dir}/"sub-*; do
    sub=$(basename "$sub_dir")
    echo "${sub} pulled successfully"
    
    # Extract the subject number from the directory name
    sub_number=$(echo "$sub" | grep -oE '[0-9]+')

    # Define mask path
    mask="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks/${mask_loc}"

    # Define input files for fslmeants command using find
    input_files=$(find "${sub_dir}" -name '*.nii.gz' -type f)
    echo "Pulled inputs: ${input_files}"

    # Run fslmeants command with the mask for each zstat file
    for file in $input_files; do
        echo "${file} is being run"
        # Extracting the number from the directory name
        number=$(basename "$file" | grep -oE '^[0-9]+')
        # Renaming the file and moving it to the destination directory
        cp "$file" "${dest_dir}/${sub}_sr_zstat${number}.nii.gz"
        # Running fslmeants command with the renamed file
        fslmeants -i "${dest_dir}/${sub}_sr_zstat${number}.nii.gz" \
                  -m "${mask}" --showall \
                  -o "${dest_dir}/${sub}_${roi}_sr_zstat${number}.csv"
        echo "Created successfully ${number}"
    done
done
