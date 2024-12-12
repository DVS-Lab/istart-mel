#!/bin/bash

# This run_* script is a wrapper for L3stats.sh, so it will loop over several
# copes and models. Note that Contrast N for PPI is always PHYS in these models.

# Ensure paths are correct irrespective of where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# Create log file to record what we did and when
logs=$maindir/logs
logfile=${logs}/rerunL3_date-`date +"%FT%H%M"`.log

# Define the types of analyses that will go into the group comparisons
for analysis in act; do # act ppi_seed-VS_thr5 ppi_seed-NAcc act nppi-dmn nppi-ecn ppi_seed | type-${type}_run-01
	analysistype=type-${analysis}

	# Define the cope numbers and names for copes 24 and 25 only
	for copeinfo in "24 F-SC_rew-pun" "25 F-SC_pun-rew"; do

		# Split copeinfo variable
		set -- $copeinfo
		copenum=$1
		copename=$2

		# Skip cases where copeinfo doesn't apply to the analysis type
		if [ "${analysistype}" == "type-act" ] && [ "${copeinfo}" == "23 phys" ]; then
			echo "Skipping phys for activation since it does not exist..."
			continue
		fi

		# Rename copeinfo variable for specific analyses if necessary
		if [ "${analysistype}" == "type-act" ] && [ "${copeinfo}" == "24 F-SC_rew-pun" ]; then
			copenum=24
			copename=F-SC_rew-pun
		elif [ "${analysistype}" == "type-act" ] && [ "${copeinfo}" == "25 F-SC_pun-rew" ]; then
			copenum=25
			copename=F-SC_pun-rew
		fi

		# Limit the number of concurrent processes
		NCORES=10
		SCRIPTNAME=${maindir}/code/L3stats.sh
		while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
			sleep 1s
		done
		# Run the main script
		bash $SCRIPTNAME $copenum $copename $analysistype $logfile #&
		sleep 1s

	done
done
