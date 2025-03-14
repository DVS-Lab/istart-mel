#!/bin/bash

# load modules and go to workdir
module load fsl/6.0.7.9
source $FSLDIR/etc/fslconf/fsl.sh

# ensure paths are correct
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa #this should be the only line that has to change if the rest of the script is set up correctly
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code

TASK=doors # or doors or socialdoors
num=1 # model number, 1 (socdoors) or 2 (sharedreward)
ppi=0
sm=6

# need to change this to a more targetted list of subjects
# also should only run this if the inputs exist. add if statements.
#for sub in `ls -1d ${maindir}/derivatives/fsl/sub-*`; do
for sub in `cat $scriptdir/newsubs.txt`; do
# CHANGE RUN TO 1 FOR SOCIALDOORS TASKS IN BELOW LINE
		for run in 1; do
	
        # Zero-padding for run variable in inputs if sub is three characters
        if [ ${#sub} -eq 3 ]; then
            run_padded=$(printf "%02d" $run)
        else
            run_padded=$run
        fi

			# set inputs and general outputs (should not need to chage across studies in Smith Lab)
			MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
	
			# if network (ecn or dmn), do nppi; otherwise, do activation or seed-based ppi
			if [ "$ppi" == "ecn" -o  "$ppi" == "dmn" ]; then
				OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${num}_type-melodic-nppi-${ppi}_run-${run_padded}_sm-${sm}
			else # otherwise, do activation and seed-based ppi
				# set output based in whether it is activation or ppi
				if [ "$ppi" == "0" ]; then
					TYPE=act
					OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${num}_type-${TYPE}_run-${run_padded}_sm-${sm}
				else
					TYPE=ppi
					OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-${num}_type-${TYPE}_seed-${ppi}_run-${run_padded}_sm-${sm}
				fi
			fi
	
			echo "fix registration and deleting unused files: $OUTPUT"
			
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

	done
done