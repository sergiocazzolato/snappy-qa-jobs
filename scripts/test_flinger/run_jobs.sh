#!/bin/bash
set -e
echo "Running testflinger client"

for FILE in $TF_DATA/*.yaml; do 
	export TF_JOB=$FILE
    . $SCRIPTS/test_flinger/run_job.sh &
done
