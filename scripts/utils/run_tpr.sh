#!/bin/bash
set -ex
echo "Running tpr"

OUTPUT="$(tpr -channel $CHANNEL -release $BRANCH)"
JOBS=$(echo $OUTPUT | cut -d "[" -f2 | cut -d "]" -f1)

for JOB in $JOBS; do
	NAME=$(basename "$JOB")
	sudo mv $JOB $TF_DATA/$NAME.yaml
done
