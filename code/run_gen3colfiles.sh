#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa

for sub in `cat ${scriptdir}/newsubs.txt`; do
	bash ${scriptdir}/gen3colfiles.sh $sub
done