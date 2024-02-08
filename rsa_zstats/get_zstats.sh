# source directory for subject data
source_dir="/ZPOOL/data/projects/istart-melanie/sharedreward/derivatives/fsl"

# destination directory for subject data for RSA
dest_dir="/ZPOOL/data/projects/istart-melanie/rsa_zstats"

for sub_folder in "$source_dir"/sub*/; do
    # Check if the sub_folder is a directory
    if [ -d "$sub_folder" ]; then
        # Extract the subject name from the sub_folder
        sub_name=$(basename "$sub_folder")
        # Echo statement
        echo "Extracted ${sub_name} name"
        # Create a subfolder for the subject in the destination directory
        sub_dest="$dest_dir/$sub_name"
        mkdir -p "$sub_dest"
			# Echo statement
		  echo "Created subfolder for ${sub_name}"
        # Iterate through folders starting with "L2" inside the sub_folder
        for L2_folder in "$sub_folder"L2*/; do
            # Check if L2_folder is a directory
            if [ -d "$L2_folder" ]; then
                # Iterate through folders starting with "cope"
                for cope_folder in "$L2_folder"cope*/; do
                    # Check if the cope_folder is a directory
                    if [ -d "$cope_folder" ]; then
                    # Iterate through "stats" folders 
                    	for stats_folder in "$cope_folder"stats*/; do
                    		if [ -d "$stats_folder" ]; then
                    		# Get cope folder info
                    		cope_name=$(basename "$cope_folder" | sed 's/\.feat//')
                    		# Copy zstat file with cope name appended for ID
                    		cp "$stats_folder"zstat*.nii.gz "$sub_dest"/"${cope_name}_zstat.nii.gz"
                    		fi
                    	done
                    fi
                done
            fi
        done
    fi
done