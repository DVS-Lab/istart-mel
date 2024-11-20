#!/usr/bin/env bash

# Ensure paths are correct irrespective of where the user runs the script
task="socdoors" # DONT TOUCH
folder="socialdoors" # "doors" # Change to appropriate source folder
roi="ramyg" # "lamyg" "ramyg" "vmpfc" "vs" "tpj" # change to ROI 
mask_src="rHarvardOxford_right-amygdala_nan_thr_bin.nii.gz" # make sure mask matches ROI
# "rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz" 
# "rHarvardOxford_right-amygdala_nan_thr_bin.nii.gz" 
# "seed-pTPJ-bin.nii" 
# "seed-vmPFC-5mm-thr.nii"
# "seed-VS_thr5.nii.gz"
mask="/ZPOOL/data/projects/istart-mel/updated_rsa/masks/${mask_src}"
dest_task="social" # doors sharedreward

source_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/${task}"
dest_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/data/${dest_task}"

# Iterate through each subject folder in the source directory
for sub_dir in "${source_dir}/${folder}/"sub-*; do
    sub=$(basename "$sub_dir")
    echo "${sub} processing started"

    # Locate the zstat4.nii.gz file only
    input_file=$(find "${sub_dir}" -name 'zstat4.nii.gz' -type f)
    
    if [[ -f "$input_file" ]]; then
        echo "Processing ${input_file}"
        
        # Define the full subject directory under the correct dest_task (social or doors)
        mkdir -p "${dest_dir}" # Ensure the subject directory exists
        
        # Copy the file to the destination directory
        cp "$input_file" "${dest_dir}/${sub}_${dest_task}_zstat4.nii.gz"
        
        # Run fslmeants command to get voxel-wise mean values within the ROI
        fslmeants -i "${dest_dir}/${sub}_${dest_task}_zstat4.nii.gz" \
                  -m "${mask}" \
                  -o "${dest_dir}/${sub}_${roi}_${dest_task}_zstat4.txt" --showall
        
        echo "Voxel-wise means saved for ${sub}"
    else
        echo "zstat4.nii.gz file not found for ${sub}"
    fi
done