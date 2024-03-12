# Source directory for subject data
source_dir="/ZPOOL/data/projects/istart-sharedreward/derivatives/fsl"

# Destination directory for subject data for RSA
dest_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward"

# Output file for subjects with missing zstat files
output_file="/ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward/output_missing_zstats.txt"

# Initialize an array to store subjects with missing zstat files
missing_zstat_subjects=()

# Loop through subject folders
for sub_folder in "$source_dir"/sub*/; do
    # Extract the subject name from the sub_folder
    sub_name=$(basename "$sub_folder")
    echo "Processing subject: ${sub_name}"

    # Create a subfolder for the subject in the destination directory
    sub_dest="$dest_dir/$sub_name"
    mkdir -p "$sub_dest"

    # Initialize a counter for the number of zstat files found
    num_zstat_files=0

    # Loop through L2 activation map folders
    for L2_folder in "$sub_folder"L2_task-sharedreward_model-3_type-act*/; do
        # Loop through cope folders
        for cope_folder in "$L2_folder"cope*/; do
            # Extract cope number without ".feat" extension
            cope_number=$(basename "$cope_folder" | sed 's/^cope\([0-9]\+\)\.feat/\1/')
            # Check if cope number is within 1-6
            if [ "$cope_number" -ge 1 ] && [ "$cope_number" -le 6 ]; then
                # Check if zstat1 file exists
                if [ -f "$cope_folder/stats/zstat1.nii.gz" ]; then
                    cp "$cope_folder/stats/zstat1.nii.gz" "$sub_dest/${cope_number}_zstat1.nii.gz"
                    echo "Copied zstat1 for cope $cope_number to $sub_dest"
                    # Increment the counter
                    ((num_zstat_files++))
                fi
            fi
        done
    done

    # Check if the number of zstat files found is less than 6
    if [ "$num_zstat_files" -ne 6 ]; then
        missing_zstat_subjects+=("$sub_name")
    fi
done

# Output the list of subjects with missing zstat files to a text file
if [ ${#missing_zstat_subjects[@]} -gt 0 ]; then
    echo "Subjects with missing zstat files:" > "$output_file"
    printf '%s\n' "${missing_zstat_subjects[@]}" >> "$output_file"
    echo "List of subjects with missing zstat files written to: $output_file"
else
    echo "All subjects have all six zstat files."
fi
