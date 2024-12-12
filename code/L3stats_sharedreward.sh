#!/bin/bash

# This script performs Level 3 statistics in FSL for single group average analysis,
# specifically for copes 24 and 25.

# Ensure paths are correct irrespective of where the user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# Study-specific inputs and general output folder
task=sharedreward
N=39
REPLACEME=$1 # This defines the parts of the path that differ across analyses
logfile=$2

MAINOUTPUT=${maindir}/derivatives/fsl/L3_model-2_task-${task}_n${N}_rsa
mkdir -p $MAINOUTPUT

# Loop through copes 24 and 25
for copenum in 24 25; do
    copename="cope${copenum}" # Customize this if cope names vary
    cnum_pad=$(printf "%02d" ${copenum}) # Padding copenum to 2 digits
    OUTPUT=${MAINOUTPUT}/L3_task-${task}_${REPLACEME}_cnum-${cnum_pad}_cname-${copename}_onegroup

    if [ -e ${OUTPUT}.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz ]; then
        # Run randomise if output doesn't exist
        cd ${OUTPUT}.gfeat/cope1.feat
        if [ ! -e randomise_tfce_corrp_tstat2.nii.gz ]; then
            randomise -i filtered_func_data.nii.gz -o randomise -d design.mat -t design.con -m mask.nii.gz -T -c 2.6 -n 10000
        fi
    else
        # Log and remove partial output if it exists
        echo "running: ${OUTPUT}" >> $logfile
        rm -rf ${OUTPUT}.gfeat

        # Create template and run FEAT analyses
        ITEMPLATE=${maindir}/templates/L3_template_n${N}.fsf
        OTEMPLATE=${MAINOUTPUT}/L3_task-${task}_${REPLACEME}_copenum-${cnum_pad}.fsf
        sed -e 's@OUTPUT@'$OUTPUT'@g' \
            -e 's@COPENUM@'$copenum'@g' \
            -e 's@REPLACEME@'$REPLACEME'@g' \
            -e 's@BASEDIR@'$maindir'@g' \
            <$ITEMPLATE> $OTEMPLATE
        feat $OTEMPLATE
    fi

    # Delete unused files to save space
    rm -rf ${OUTPUT}.gfeat/cope1.feat/stats/res4d.nii.gz
    rm -rf ${OUTPUT}.gfeat/cope1.feat/stats/corrections.nii.gz
    rm -rf ${OUTPUT}.gfeat/cope1.feat/stats/threshac1.nii.gz
    rm -rf ${OUTPUT}.gfeat/cope1.feat/stats/var_filtered_func_data.nii.gz
done
