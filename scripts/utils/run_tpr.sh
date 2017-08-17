#!/bin/bash

echo "Running tpr command: tpr -channel $CHANNEL -from $CHANNEL_FROM -release $BRANCH"

OUTPUT="$(tpr -channel $CHANNEL -from $CHANNEL_FROM -release $BRANCH)"
JOBS=$(echo $OUTPUT | cut -d "[" -f2 | cut -d "]" -f1)

echo "Moving jobs: $JOBS"
for JOB in $JOBS; do
	NAME=$(basename "$JOB")
	sudo mv $JOB $TF_DATA/$NAME.yaml
done

