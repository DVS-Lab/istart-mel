#!/usr/bin/env bash

# Script arguments
sub=$1
task=$2
mask_shortname=$3

# Paths and directories # I'm sorrrryyyyy for hard coding
data_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl"
output_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/rawactivation_output"
mask_dir="/ZPOOL/data/projects/istart-mel/updated_rsa/masks/resliced/resliced_bin"

# Map shortened mask names back to full file names for sourcing
declare -A masks
masks=(
    ["lamyg"]="rHarvardOxford_left-amygdala_nan_thr_bin.nii.gz"
    ["ramyg"]="rHarvardOxford_right-amygdala_nan_thr_bin.nii.gz"
    ["vs"]="seed-VS_thr5.nii.gz"
    ["vmpfc"]="seed-vmPFC-5mm-thr.nii"
    ["tpj"]="seed-pTPJ-bin.nii"
    ["amyg"]="rHarvardOxford_amygdala_nan_thr_bin.nii.gz"
    ["V1"]="V1_control_thr.nii.gz"
)

# Ensure mask exists
mask=${masks[$mask_shortname]}
if [ -z "$mask" ]; then
    echo "Invalid mask: $mask_shortname"
    exit 1
fi

# Define raw activation paths with descriptive labels
act_stranger="${data_dir}/sub-${sub}/L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope25.feat/stats/cope1.nii.gz"
act_computer="${data_dir}/sub-${sub}/L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope24.feat/stats/cope1.nii.gz"
act_socialdoors="${data_dir}/sub-${sub}/L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/cope4.nii.gz"
act_doors="${data_dir}/sub-${sub}/L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/cope4.nii.gz"

# Process each activation file
declare -A act_tasks
act_tasks=(
    ["$act_stranger"]="stranger"
    ["$act_computer"]="computer"
    ["$act_socialdoors"]="socialdoors"
    ["$act_doors"]="doors"
)

for act in "$act_stranger" "$act_computer" "$act_socialdoors" "$act_doors"; do
    act_name=$(basename "$act" .nii.gz)
    task_label="${act_tasks[$act]}_${act_name}"

    if [ -f "$act" ]; then
        output_csv="${output_dir}/raw/sub-${sub}_${task_label}_${mask_shortname}.csv"

        # Run fslmeants
        fslmeants -i "$act" \
        -m "${mask_dir}/${mask}" --showall \
        -o "$output_csv"

        echo "Processed: $act -> $output_csv"
    else
        echo "File not found: $act"
    fi
done