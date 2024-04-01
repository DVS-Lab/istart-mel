# Source directory for subject data
source_dir="/ZPOOL/data/projects/istart-melanie/socdoors/derivatives/fsl"

# Destination directory for subject data for RSA
dest_dir="/ZPOOL/data/projects/istart-mel/rsa_zstats/socdoors/socialdoors"

for sub_folder in "$source_dir"/sub*/; do
    # Check if the sub_folder is a directory
    if [ -d "$sub_folder" ]; then
        # Extract the subject name from the sub_folder
        sub_name=$(basename "$sub_folder")
        # Echo statement to verify
        echo "Extracted ${sub_name}"
        # Create a subfolder for the subject in the destination directory
        sub_dest="$dest_dir/$sub_name"
        mkdir -p "$sub_dest"
			# Echo statement to verify
		  echo "Created subfolder for ${sub_name}"
        # Iterate through folders starting with "L1" inside the sub_folder
        for L1_folder in "$sub_folder"L1_task-socialdoors_model-1_type-act*/; do
        # change into L1 / pull from L1 dir
            # Check if L1_folder is a directory
            if [ -d "$L1_folder" ]; then
            	for stats_folder in "$L1_folder"stats*/; do
            		if [ -d "$stats_folder" ]; then
                    	# Copy zstat file with cope name appended for ID
                    	cp "$stats_folder"zstat*.nii.gz "$sub_dest"
                    	fi
                    done
                   fi
               done
           fi
        done