#!/usr/bin/env bash

# Script to convert BIDS *events.tsv files into FSL 3-col format
# Depends on BIDSto3col.sh converter: https://github.com/bids-standard/bidsutils

datadir=/ZPOOL/data/projects/istart-mel/updated_rsa/data
baseout=/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl/EVfiles
if [ ! -d ${baseout} ]; then
  mkdir -p $baseout
fi

sub=$1

for run in 1 2; do
  input=${datadir}/bids/sub-${sub}/func/sub-${sub}_task-sharedreward_run-${run}_events.tsv
  output=${baseout}/sub-${sub}/sharedreward
  mkdir -p $output
  
  if [ -e $input ]; then
    echo "Processing input: $input for sub-${sub}, run-${run}"
    # Ensure distinct output files per run
    bash /ZPOOL/data/tools/BIDSto3col.sh $input ${output}/run-${run}
  else
    echo "PATH ERROR: cannot locate ${input} for sub-${sub}, run-${run}."
    exit 1
  fi
done