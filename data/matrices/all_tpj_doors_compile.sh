#!/bin/bash

# Directory containing the files
data_dir="/ZPOOL/data/projects/istart-mel/data/socialdoors/tpj_doors"
output_dir="/ZPOOL/data/projects/istart-mel/data/matrices"
output_csv_path="$output_dir/all_doors_tpj_mat.csv"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to extract information from file name
extract_info() {
    file_name="$1"
    sub_id=$(echo "$file_name" | cut -d'_' -f1 | cut -d'-' -f2)
    roi=$(echo "$file_name" | cut -d'_' -f2)
    if [[ "$file_name" == *"zstat1.csv"* ]]; then
        cond="doors_win"
    elif [[ "$file_name" == *"zstat2.csv"* ]]; then
        cond="doors_loss"
    else
        return
    fi
    echo "$sub_id,$roi,$cond"
}

# Function to process CSV files
process_csv() {
    file_path="$1"
    awk 'NR==4{for (i=1;i<=NF;i++) print $i}' "$file_path"
}

# Remove existing output file
rm -f "$output_csv_path"

# Write headers to output CSV
echo "sub_id,roi,cond,value" > "$output_csv_path"

# Iterate through files in the directory
for file_name in "$data_dir"/*.csv; do
    if [[ -f "$file_name" ]]; then
        sub_info=$(extract_info "$(basename "$file_name")")
        if [ -n "$sub_info" ]; then
            values=$(process_csv "$file_name")
            while IFS= read -r value; do
                echo "$sub_info,$value" >> "$output_csv_path"
            done <<< "$values"
        fi
    fi
done

echo "CSV file created at: $output_csv_path"
