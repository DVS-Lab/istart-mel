#!/usr/bin/env bash

# This script will perform Level 1 statistics in FSL.
# It handles activation analysis only (PPI/nPPI sections removed).

# Ensure paths are correct irrespective of where the user runs the script
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa

# Study-specific inputs
sm=6
sub=$1
run=$2
TASK=$3
logfile=$4

# Set inputs and general outputs
MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
mkdir -p $MAINOUTPUT
DATA=${maindir}/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${TASK}_run-${run}_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz
NVOLUMES=$(fslnvols $DATA)
CONFOUNDEVS=${maindir}/derivatives/fsl/confounds/sub-${sub}/sub-${sub}_task-${TASK}_run-${run}_desc-fslConfounds.tsv

if [ ! -e $CONFOUNDEVS ]; then
    echo "Missing confounds: $CONFOUNDEVS" >> "$logfile"
    exit
fi

EVDIR=${maindir}/derivatives/fsl/EVfiles/sub-${sub}/${TASK}/run-${run}

# Handle the "missed_trial" EV dynamically
EV_MISSED_TRIAL=${EVDIR}_decision-missed.txt
if [ -s $EV_MISSED_TRIAL ]; then
    SHAPE_MISSED_TRIAL=3
    EVDIR_MISSED_TRIAL=$EV_MISSED_TRIAL
    echo "Including missed trials EV for subject $sub, run $run" >> "$logfile"
else
    SHAPE_MISSED_TRIAL=10
    EVDIR_MISSED_TRIAL=""
    echo "No missed trials EV for subject $sub, run $run" >> "$logfile"
fi

# Activation Analysis
OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-1_type-act_run-${run}_sm-${sm}

if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
    exit
else
    echo "Missing feat output: $OUTPUT" >> "$logfile"
    rm -rf ${OUTPUT}.feat
fi

ITEMPLATE=${maindir}/templates/L1_task-${TASK}_model-1_type-act.fsf
OTEMPLATE=${MAINOUTPUT}/L1_sub-${sub}_task-${TASK}_model-1_type-act_run-${run}.fsf

sed -e 's@OUTPUT@'"$OUTPUT"'@g' \
    -e 's@DATA@'"$DATA"'@g' \
    -e 's@EVDIR_win.txt@'"${EVDIR}_win.txt"'@g' \
    -e 's@EVDIR_loss.txt@'"${EVDIR}_loss.txt"'@g' \
    -e 's@EVDIR_decision.txt@'"${EVDIR}_decision.txt"'@g' \
    -e 's@EVDIR_MISSED_TRIAL@'"$EVDIR_MISSED_TRIAL"'@g' \
    -e 's@SHAPE_MISSED_TRIAL@'"$SHAPE_MISSED_TRIAL"'@g' \
    -e 's@CONFOUNDEVS@'"$CONFOUNDEVS"'@g' \
    -e 's@NVOLUMES@'"$NVOLUMES"'@g' \
    <$ITEMPLATE> $OTEMPLATE

feat $OTEMPLATE

# NeuroStars Registration Fix
mkdir -p ${OUTPUT}.feat/reg
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
ln -s ${OUTPUT}.feat/mean_func.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

# Cleanup
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
