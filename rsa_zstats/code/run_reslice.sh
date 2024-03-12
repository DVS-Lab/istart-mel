#!/bin/bash

# Specify where reslice.py is located
scriptdir="/ZPOOL/data/projects/istart-mel/rsa_zstats/code"
NCORES=2

# Specify where zstat images are located
zstat_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward"

# Specify where mask images are located
mask_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/masks"

# Check to see if directory exists
if [ ! -d "$zstat_dir" ]; then
    echo "Error: Directory with zstat images not found."
    exit 1
fi

# Specify the path to the reslice.py script
reslice_script="${scriptdir}/reslice.py"

# Check if reslice.py exists
if [ ! -f "$reslice_script" ]; then
    echo "Error: reslice.py script not found."
    exit 1
fi

# Loop through each subject folder
for sub_folder in "$zstat_dir"/sub*; do
    if [ -d "$sub_folder" ]; then
        subject_id=$(basename "$sub_folder")
        output_sub_folder="/ZPOOL/data/projects/istart-mel/data/sharedreward/$subject_id"
        mkdir -p "$output_sub_folder"

        # Loop through zstat images 1-6
        for ((i=1; i<=6; i++)); do
            zstat_file="$sub_folder/${i}_zstat.nii.gz"
            if [ -f "$zstat_file" ]; then
                echo "Using $zstat_file as the template file"
                # Loop through mask files
                for mask_file in "$mask_dir"/*.nii.gz; do
                    if [ -f "$mask_file" ]; then
                        # Define output file name
                        resliced_mask_file="${output_sub_folder}/resliced_$(basename "${mask_file%.*}")_$i.nii.gz"
                        # Execute reslice.py
                        echo "Running: python \"$reslice_script\" \"$mask_file\" \"$zstat_file\" \"$resliced_mask_file\""
                        python "$reslice_script" "$mask_file" "$zstat_file" "$resliced_mask_file"
                        # Check if reslice.py executed successfully
                        if [ $? -eq 0 ]; then
                            echo "Reslice completed successfully."
                        else
                            echo "Error: Reslice failed."
                        fi
                    fi
                done
            fi
        done
    fi
done

echo "Finished"