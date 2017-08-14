#!/bin/bash
set -e
echo "Running testflinger client"

JOB_DATA=/var/snap/testflinger-cli/current
sudo cp job.yaml $JOB_DATA

JOB_ID=$(/snap/bin/testflinger-cli submit -q $JOB_DATA/job.yaml)
echo "JOB_ID: ${JOB_ID}"
/snap/bin/testflinger-cli poll ${JOB_ID}
wget -O artifacts.tgz http://testflinger.canonical.com/v1/result/$JOB_ID/artifact
tar -xzf artifacts.tgz
