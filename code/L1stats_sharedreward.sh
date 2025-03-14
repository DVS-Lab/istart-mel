#!/usr/bin/env bash

# This script will perform Level 1 statistics in FSL.
# Rather than having multiple scripts, we are merging three analyses
# into this one script:
# 	1) activation
# 	2) seed-based ppi
# 	3) network-based ppi
# Note that activation analysis must be performed first.
# Seed-based PPI and Network PPI should follow activation analyses.

# ensure paths are correct irrespective from where user runs the script
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa
istartdatadir=/ZPOOL/data/projects/istart-mel/updated_rsa

# study-specific inputs
TASK=sharedreward
sm=6
model=$1
sub=$2
run=$3
ppi=$4 # 0 for activation, otherwise seed region or network
logfile=$5
echo model: ${model} sub: ${sub} run: ${run} ppi: ${ppi} logfile: ${logfile}

# set inputs and general outputs (should not need to change across studies in Smith Lab)
MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
mkdir -p $MAINOUTPUT
DATA=${istartdatadir}/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${TASK}_run-${run}_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz
NVOLUMES=`fslnvols $DATA`
CONFOUNDEVS=${istartdatadir}/derivatives/fsl/confounds/sub-${sub}/sub-${sub}_task-${TASK}_run-${run}_desc-fslConfounds.tsv
if [ ! -e $CONFOUNDEVS ]; then
    echo "missing confounds: $CONFOUNDEVS " >> $logfile
    exit  # exiting to ensure nothing gets run without confounds
fi
EVDIR=${maindir}/derivatives/fsl/EVfiles/sub-${sub}/${TASK}/run-${run}

# empty EVs (specific to this study)
EV_MISSED_TRIAL=${EVDIR}_missed_trial.txt
if [ -e $EV_MISSED_TRIAL ]; then
    SHAPE_MISSED_TRIAL=3
else
    EV_MISSED_TRIAL=placeholder
    SHAPE_MISSED_TRIAL=10
fi

EV_COMPN=${EVDIR}_event_computer_neutral.txt
if [ -e $EV_COMPN ]; then
	SHAPE_COMPN=3
else
	EV_COMPN=placeholder
	SHAPE_COMPN=10
fi

EV_FRIENDN=${EVDIR}_event_friend_neutral.txt
if [ -e $EV_FRIENDN ]; then
	SHAPE_FRIENDN=3
else
	EV_FRIENDN=placeholder
	SHAPE_FRIENDN=10
fi

EV_STRANGERN=${EVDIR}_event_stranger_neutral.txt
if [ -e $EV_STRANGERN ]; then
	SHAPE_STRANGERN=3
else
	EV_STRANGERN=placeholder
	SHAPE_STRANGERN=10
fi

# if network (ecn or dmn), do nppi; otherwise, do activation or seed-based ppi
if [ "$ppi" == "ecn" -o  "$ppi" == "dmn" ]; then

	# check for output and skip existing
	OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${model}_type-nppi-${ppi}_run-${run}_sm-${sm}
	if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
		echo "output $OUTPUT exists, skipping"
		exit
	else
		echo "running: $OUTPUT " >> $logfile
		rm -rf ${OUTPUT}.feat
	fi

	# network extraction. need to ensure you have run Level 1 activation
	MASK=${MAINOUTPUT}/L1_task-${TASK}_model-${model}_type-act_run-${run}_sm-${sm}.feat/mask
	if [ ! -e ${MASK}.nii.gz ]; then
		echo "cannot run nPPI because you're missing $MASK"
		exit
	fi
	for net in `seq 0 9`; do
		NET=${maindir}/masks/nan_rPNAS_2mm_net000${net}.nii.gz
		TSFILE=${MAINOUTPUT}/ts_task-${TASK}_net000${net}_nppi-${ppi}_run-${run}.txt
		fsl_glm -i $DATA -d $NET -o $TSFILE --demean -m $MASK
		eval INPUT${net}=$TSFILE
	done

	# set names for network ppi (we generally only care about ECN and DMN)
	DMN=$INPUT3
	ECN=$INPUT7
	if [ "$ppi" == "dmn" ]; then
		MAINNET=$DMN
		OTHERNET=$ECN
	else
		MAINNET=$ECN
		OTHERNET=$DMN
	fi

	# create template and run analyses
	ITEMPLATE=${maindir}/templates/L1_task-${TASK}_model-${model}_type-nppi.fsf
	OTEMPLATE=${MAINOUTPUT}/L1_task-${TASK}_model-${model}_seed-${ppi}_run-${run}.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@EVDIR@'$EVDIR'@g' \
	-e 's@EV_MISSED_TRIAL@'$EV_MISSED_TRIAL'@g' \
	-e 's@SHAPE_MISSED_TRIAL@'$SHAPE_MISSED_TRIAL'@g' \
	-e 's@EV_FRIENDN@'$EV_FRIENDN'@g' \
	-e 's@SHAPE_FRIENDN@'$SHAPE_FRIENDN'@g' \
	-e 's@EV_COMPN@'$EV_COMPN'@g' \
	-e 's@SHAPE_COMPN@'$SHAPE_COMPN'@g' \
	-e 's@EV_STRANGERN@'$EV_STRANGERN'@g' \
	-e 's@SHAPE_STRANGERN@'$SHAPE_STRANGERN'@g' \
	-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
	-e 's@MAINNET@'$MAINNET'@g' \
	-e 's@OTHERNET@'$OTHERNET'@g' \
	-e 's@INPUT0@'$INPUT0'@g' \
	-e 's@INPUT1@'$INPUT1'@g' \
	-e 's@INPUT2@'$INPUT2'@g' \
	-e 's@INPUT4@'$INPUT4'@g' \
	-e 's@INPUT5@'$INPUT5'@g' \
	-e 's@INPUT6@'$INPUT6'@g' \
	-e 's@INPUT8@'$INPUT8'@g' \
	-e 's@INPUT9@'$INPUT9'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	<$ITEMPLATE> $OTEMPLATE
	feat $OTEMPLATE

else # otherwise, do activation and seed-based ppi

	# set output based in whether it is activation or ppi
	if [ "$ppi" == "0" ]; then
		TYPE=act
		OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${model}_type-${TYPE}_run-${run}_sm-${sm}
	else
		TYPE=ppi
		OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${model}_type-${TYPE}_seed-${ppi}_run-${run}_sm-${sm}
	fi

	# check for output and skip existing
	if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
		echo "output $OUTPUT exists"
		exit
	else
		echo "running: $OUTPUT " >> $logfile
		rm -rf ${OUTPUT}.feat
	fi

	# create template and run analyses
	ITEMPLATE=${maindir}/templates/L1_task-${TASK}_model-${model}_type-${TYPE}.fsf
	OTEMPLATE=${MAINOUTPUT}/L1_sub-${sub}_task-${TASK}_model-${model}_seed-${ppi}_run-${run}.fsf
	if [ "$ppi" == "0" ]; then
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@DATA@'$DATA'@g' \
		-e 's@EVDIR@'$EVDIR'@g' \
		-e 's@EV_MISSED_TRIAL@'$EV_MISSED_TRIAL'@g' \
		-e 's@SHAPE_MISSED_TRIAL@'$SHAPE_MISSED_TRIAL'@g' \
		-e 's@EV_FRIENDN@'$EV_FRIENDN'@g' \
		-e 's@SHAPE_FRIENDN@'$SHAPE_FRIENDN'@g' \
		-e 's@EV_COMPN@'$EV_COMPN'@g' \
		-e 's@SHAPE_COMPN@'$SHAPE_COMPN'@g' \
		-e 's@EV_STRANGERN@'$EV_STRANGERN'@g' \
		-e 's@SHAPE_STRANGERN@'$SHAPE_STRANGERN'@g' \
		-e 's@SMOOTH@'$sm'@g' \
		-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
		-e 's@NVOLUMES@'$NVOLUMES'@g' \
		<$ITEMPLATE> $OTEMPLATE
	else
		PHYS=${MAINOUTPUT}/ts_task-${TASK}_mask-${ppi}_run-${run}.txt
		MASK=${maindir}/masks/seed-${ppi}.nii.gz
		fslmeants -i $DATA -o $PHYS -m $MASK
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@DATA@'$DATA'@g' \
		-e 's@EVDIR@'$EVDIR'@g' \
		-e 's@EV_MISSED_TRIAL@'$EV_MISSED_TRIAL'@g' \
		-e 's@SHAPE_MISSED_TRIAL@'$SHAPE_MISSED_TRIAL'@g' \
		-e 's@EV_FRIENDN@'$EV_FRIENDN'@g' \
		-e 's@SHAPE_FRIENDN@'$SHAPE_FRIENDN'@g' \
		-e 's@EV_COMPN@'$EV_COMPN'@g' \
		-e 's@SHAPE_COMPN@'$SHAPE_COMPN'@g' \
		-e 's@EV_STRANGERN@'$EV_STRANGERN'@g' \
		-e 's@SHAPE_STRANGERN@'$SHAPE_STRANGERN'@g' \
		-e 's@PHYS@'$PHYS'@g' \
		-e 's@SMOOTH@'$sm'@g' \
		-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
		-e 's@NVOLUMES@'$NVOLUMES'@g' \
		<$ITEMPLATE> $OTEMPLATE
	fi
	feat $OTEMPLATE
fi

# fix registration as per NeuroStars post:
# https://neurostars.org/t/performing-full-glm-analysis-with-fsl-on-the-bold-images-preprocessed-by-fmriprep-without-re-registering-the-data-to-the-mni-space/784/3
mkdir -p ${OUTPUT}.feat/reg
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
ln -s ${OUTPUT}.feat/mean_func.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

# delete unused files
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
