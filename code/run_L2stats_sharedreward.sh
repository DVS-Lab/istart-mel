#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa

# create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL2_date-`date +"%FT%H%M"`.log

# the "type" variable below is setting a path inside the main script
for type in "act"; do # "act" ppi_seed-VS_thr5 ppi_seed-NAcc act nppi-ecn nppi-dmn
	for sub in `cat ${scriptdir}/newsubs.txt`; do
		# Manages the number of jobs and cores
  	SCRIPTNAME=${maindir}/code/L2stats.sh
  	NCORES=10
  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
    		sleep 1s
  	done
  	bash $SCRIPTNAME $sub $type $logfile &
  	sleep 1s

	done
done