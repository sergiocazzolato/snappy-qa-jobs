#!/bin/bash
set -ex
echo "Running testflinger client"

for FILE in $TF_DATA/*.yaml; do
	export TF_JOB=$FILE
    . $SCRIPTS_DIR/test_flinger/run_job.sh &
done
