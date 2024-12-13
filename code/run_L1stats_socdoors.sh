#!/bin/bash

# Ensure paths are correct irrespective of where user runs the script
scriptdir=/ZPOOL/data/projects/istart-mel/updated_rsa/code
maindir=/ZPOOL/data/projects/istart-mel/updated_rsa

# create log file to record what we did and when
logs=${maindir}/logs
logfile=${logs}/rerunL1_socdoors_date-$(date +"%FT%H%M").log

# For task doors
for sub in $(cat ${scriptdir}/newsubs.txt); do
    SCRIPTNAME=${scriptdir}/L1stats_socdoors.sh
    NCORES=5
    while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
        sleep 5s
    done
    # Run the main script for each subject and task
    bash $SCRIPTNAME $sub 1 doors $logfile &
    sleep 1s
done

# For task socialdoors
for sub in $(cat ${scriptdir}/newsubs.txt); do
    SCRIPTNAME=${scriptdir}/L1stats_socdoors.sh
    NCORES=5
    while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
        sleep 5s
    done
    # Run the main script for each subject and task
    bash $SCRIPTNAME $sub 1 socialdoors $logfile &
    sleep 1s
done
