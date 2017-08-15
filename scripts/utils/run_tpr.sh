#!/bin/bash
set -e
echo "Running tpr"

OUTPUT="$(tpr -channel $CHANNEL -release $RELEASE)"
JOBS=$(echo $OUTPUT | cut -d "[" -f2 | cut -d "]" -f1)

for JOB in $JOBS; do
	NAME=$(basename "$JOB")
	sudo cp $JOB $TF_DATA/$NAME.yaml
done

