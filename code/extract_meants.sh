#!/usr/bin/env bash

# Script arguments
sub=$1
task=$2
mask_shortname=$3

# Paths and directories # I'm sorrrryyyyy for hard coding
data_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl"
output_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/meants_output"
mask_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/masks/resliced/resliced_bin"

# Map shortened mask names back to full file names for sourcing
declare -A masks
masks=(
    ["lamyg"]="rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz"
    ["ramyg"]="rHarvardOxford_right-amygdala_nan_thr_bin.nii.gz"
    ["vs"]="seed-VS_thr5.nii.gz"
    ["vmpfc"]="seed-vmPFC-5mm-thr.nii"
    ["tpj"]="seed-pTPJ-bin.nii"
)

# Ensure mask exists
mask=${masks[$mask_shortname]}
if [ -z "$mask" ]; then
    echo "Invalid mask: $mask_shortname"
    exit 1
fi

# Define zstat paths with descriptive labels
zstat_stranger="${data_dir}/sub-${sub}/L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope25.feat/stats/zstat1.nii.gz"
zstat_computer="${data_dir}/sub-${sub}/L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope24.feat/stats/zstat1.nii.gz"
zstat_socialdoors="${data_dir}/sub-${sub}/L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat4.nii.gz"
zstat_doors="${data_dir}/sub-${sub}/L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat4.nii.gz"

# Process each zstat file
declare -A zstat_tasks
zstat_tasks=(
    ["$zstat_stranger"]="stranger"
    ["$zstat_computer"]="computer"
    ["$zstat_socialdoors"]="socialdoors"
    ["$zstat_doors"]="doors"
)

for zstat in "$zstat_stranger" "$zstat_computer" "$zstat_socialdoors" "$zstat_doors"; do
    zstat_name=$(basename "$zstat" .nii.gz)
    task_label="${zstat_tasks[$zstat]}_${zstat_name}"

    if [ -f "$zstat" ]; then
        output_csv="${output_dir}/raw/sub-${sub}_${task_label}_${mask_shortname}.csv"

        # Run fslmeants
        fslmeants -i "$zstat" \
        -m "${mask_dir}/${mask}" --showall \
        -o "$output_csv"

        echo "Processed: $zstat -> $output_csv"
    else
        echo "File not found: $zstat"
    fi
done