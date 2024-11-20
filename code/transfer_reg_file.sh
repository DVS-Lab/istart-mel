#!/bin/bash

# Base directory
BASE_DIR="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl"

# Loop through all subject folders
for SUBJ in ${BASE_DIR}/sub-*; do
    SRC_DIR="$SUBJ/L1_task-sharedreward_model-2_type-act_run-1_sm-6+.feat"
    DEST_DIR="$SUBJ/L1_task-sharedreward_model-2_type-act_run-1_sm-6.feat"
    
    # Check if both source and destination directories exist
    if [ -d "$SRC_DIR" ] && [ -d "$DEST_DIR" ]; then
        echo "Syncing contents from $SRC_DIR to $DEST_DIR"
        
        # Use rsync to move contents while avoiding overwriting duplicates
        rsync -av --ignore-existing "$SRC_DIR/" "$DEST_DIR/"
        
        # Remove the source directory after sync
        echo "Removing $SRC_DIR"
        rm -rf "$SRC_DIR"
    else
        echo "Skipping $SUBJ: Required directories not found."
    fi
done

echo "Transfer and cleanup complete!"