#!/bin/bash

# Paths and directories # I'm sorryyyy for hard coding
scriptdir="/ZPOOL/data/projects/istart-mel/updated_rsa/code"
basedir="/ZPOOL/data/projects/istart-mel/updated_rsa"
log_dir="${basedir}/logs"
output_dir="${basedir}/rawactivation_output"
newsubs_file="${scriptdir}/newsubs.txt"
extract_script="${scriptdir}/extract_rawactivation.sh"
NCORES=10

# Ensure required files exist
if [ ! -s "$newsubs_file" ]; then
    echo "Error: Subjects file $newsubs_file not found or empty."
    exit 1
fi

if [ ! -f "$extract_script" ]; then
    echo "Error: Extraction script $extract_script not found."
    exit 1
fi

# Tasks, masks, and subjects
tasks=("sharedreward" "socialdoors" "doors")
masks=("amyg" "lamyg" "ramyg" "vs" "vmpfc" "tpj" "V1")
subjects=$(cat "$newsubs_file")

mkdir -p "$log_dir"
log_file="${log_dir}/extract_rawactivation_$(date +'%Y%m%d_%H%M%S').log"
echo "Starting extraction process: $(date)" > "$log_file"

# Function to run extraction
run_extraction() {
    local sub=$1
    local task=$2
    local mask=$3
    echo "Running extraction for Sub: $sub, Task: $task, Mask: $mask" >> "$log_file"
    bash "$extract_script" "$sub" "$task" "$mask" >> "$log_file" 2>&1
}

# Loop through tasks, masks, and subjects
for task in "${tasks[@]}"; do
    for mask in "${masks[@]}"; do
        for sub in $subjects; do

            # Manage job concurrency
            while [ "$(pgrep -f $extract_script | wc -l)" -ge "$NCORES" ]; do
                sleep 5s
            done

            # Run extraction
            run_extraction "$sub" "$task" "$mask" &

            # Sleep briefly to stagger jobs
            sleep 1s
        done
    done
done

# Wait for all background jobs to complete
wait

echo "All extractions complete: $(date)" >> "$log_file"
echo "Log file saved to $log_file"