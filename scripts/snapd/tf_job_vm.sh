#!/bin/bash
set -ex

DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
SPREAD_SUITE=$4

WORKSPACE=$(pwd)
RESULTS=$WORKSPACE/results
mkdir $RESULTS

JOB_DATA=/var/snap/testflinger-cli/current
cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  distro: xenial
test_data:
  test_cmds: |
    mkdir artifacts
    ssh ubuntu@{device_ip} "git clone https://github.com/sergiocazzolato/snappy-jenkins-jobs.git"
    ssh ubuntu@{device_ip} "./snappy-jenkins-jobs/scripts/snapd/run_spread_vm.sh $ARCHITECTURE $CHANNEL $SPREAD_SUITE NO_PROXY"
    scp ubuntu@{device_ip}:~/snapd/report.xml artifacts/report.xml
  test_username: admin
  test_password: admin
EOF
sudo cp job.yaml $JOB_DATA/job.yaml

JOB_ID=$(/snap/bin/testflinger-cli submit -q $JOB_DATA/job.yaml)
echo "JOB_ID: ${JOB_ID}"
/snap/bin/testflinger-cli poll ${JOB_ID}
wget -O artifacts.tgz http://testflinger.canonical.com/v1/result/$JOB_ID/artifact
tar -xzf artifacts.tgz
