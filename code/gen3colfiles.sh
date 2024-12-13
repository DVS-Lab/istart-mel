#!/usr/bin/env bash

# this script will convert your BIDS *events.tsv files into the 3-col format for FSL
# it relies on Tom Nichols' converter, which we store locally under /data/tools
# https://github.com/bids-standard/bidsutils

# note: has to be run from Smith Lab Linux box

# To do:
# 1) add parametric modulators?
# 2) log missing inputs?
# 3) zero padding for run number. fix at heudiconv conversion

datadir=/ZPOOL/data/projects/istart-mel/updated_rsa/data

scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa
baseout=${maindir}/derivatives/fsl/EVfiles
if [ ! -d ${baseout} ]; then
  mkdir -p $baseout
fi

sub=$1


for run in 1 2; do # 1 2 for shared reward 1 for doors socialdoors
  # input=${datadir}/bids/sub-${sub}/func/sub-${sub}_task-doors_run-${run}_events.tsv
  # input=${datadir}/bids/sub-${sub}/func/sub-${sub}_task-socialdoors_run-${run}_events.tsv
  input=${datadir}/bids/sub-${sub}/func/sub-${sub}_task-sharedreward_run-${run}_events.tsv
  output=${baseout}/sub-${sub}/sharedreward # socialdoors # doors #sharedreward
  mkdir -p $output
  if [ -e $input ]; then 
    bash /ZPOOL/data/tools/BIDSto3col.sh $input ${output}/run-${run}
  else
    echo "PATH ERROR: cannot locate ${input}."
    exit
  fi
done