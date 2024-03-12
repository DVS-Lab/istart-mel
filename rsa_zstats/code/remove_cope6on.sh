# Go to directory containing the subfolders
cd /ZPOOL/data/projects/istart-mel/rsa_zstats/sharedreward

# Loop through each subject folder
for sub_folder in sub-*; do
    echo "Processing subject: $sub_folder"
    # Navigate to sub folder
    cd "$sub_folder"
    
    # Loop through zstats pulled from copes 7+ (7 to 23)
    for ((num=7; num<=23; num++)); do
        # Remove files starting with the current number
        rm -f "${num}"_zstat1.nii.gz
    done
    
    # Navigate back to the parent directory
    cd ..
done

echo "zstats from copes 7 to 23 have been removed from all subject folders"