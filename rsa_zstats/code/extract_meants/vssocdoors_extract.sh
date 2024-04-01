#!/usr/bin/env bash

# Ensure paths are correct irrespective from where user runs the script
source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats"
dest_dir="/ZPOOL/data/projects/istart-mel/data/socialdoors/vs_socdoors"

# Iterate through each subject folder in the doors directory
for sub_dir in "${source_dir}/socdoors/socialdoors/"sub-*; do
    sub=$(basename "$sub_dir")
		echo "${sub} pulled successfully"
    # Define mask path
    mask="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks/seed-VS_thr5.nii.gz"

    # Define input files for fslmeants command using find
    input_files=$(find "${sub_dir}" -name 'zstat*.nii.gz' -type f)
		echo "Pulled inputs: ${input_files}"
    # Run fslmeants command with the mask for each zstat file
    for file in $input_files; do
    	echo "${file} is being run"
    	number=$(echo "$file" | grep -oP 'zstat\K\d+(?=.nii.gz)') 
        fslmeants -i $file \
                  -m "${mask}" \
                  -o "${dest_dir}/${sub}_socialdoors_zstat${number}.txt"
      echo "Created successfully ${number}"
    done
done