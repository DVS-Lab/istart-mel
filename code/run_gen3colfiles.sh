#!/bin/bash

# Wrapper script to run gen3colfiles.sh for all subjects
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code

for sub in $(cat ${scriptdir}/newsubs.txt); do
    echo "Generating EV files for subject: $sub"
    bash ${scriptdir}/gen3colfiles.sh $sub
    if [ $? -ne 0 ]; then
        echo "Error processing subject: $sub" >> ${scriptdir}/error.log
    fi
done