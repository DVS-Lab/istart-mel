#!/bin/bash

# Define the regions of interest
regions=('vs' 'vmpfc' 'lamyg' 'ramyg' 'tpj')

# Define the directory containing the CSV files
csv_dir="/ZPOOL/data/projects/istart-mel/data/matrices/all_socdoors_mats"

# Iterate over each region
for region in "${regions[@]}"; do
    # Create an empty output file for the region
    output_file="/ZPOOL/data/projects/istart-mel/data/matrices/${region}_socialdoors.csv"
    echo "sub_id,condition,value" > "$output_file"

    # Iterate over each CSV file in the directory
    for csv_file in "$csv_dir"/*.csv; do
        # Check if the CSV file is for the current region
        if [[ "$csv_file" == *"${region}_mat.csv" ]]; then
            # Extract sub_id, condition, and value columns
            awk -F'\t' 'NR>1 {print $1","$3","$4}' "$csv_file" >> "$output_file"
        fi
    done
done
