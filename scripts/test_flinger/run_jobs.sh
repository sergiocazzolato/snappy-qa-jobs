#!/bin/bash

echo "Running testflinger client"

for FILE in $TF_DATA/*.yaml; do
	export TF_JOB=$FILE
	cat $TF_JOB
    . "$SCRIPTS_DIR/test_flinger/run_job.sh" &
done
