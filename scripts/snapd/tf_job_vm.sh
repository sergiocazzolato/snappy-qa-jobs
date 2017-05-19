#!/bin/bash
set -e

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
BRANCH=$4
SPREAD_TESTS=$5
SETUP=$6

PROJECT=snapd
PROJECT_URL=https://github.com/snapcore/snapd.git
JOBS_URL=https://github.com/sergiocazzolato/snappy-jenkins-jobs.git

HOST=localhost
PORT=8022
DEVICE_USER=ubuntu
TEST_USER=test

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  distro: xenial
test_data:
  test_cmds: |
    mkdir artifacts
    ssh $DEVICE_USER@{device_ip} "git clone $JOBS_URL"
    ssh $DEVICE_USER@{device_ip} "./snappy-jenkins-jobs/scripts/utils/create_vm.sh $ARCHITECTURE $CHANNEL NO_PROXY $PORT"
    ssh $DEVICE_USER@{device_ip} "git clone $PROJECT_URL"
    ssh $DEVICE_USER@{device_ip} "cd $PROJECT && git checkout $BRANCH && cd .."
    ssh $DEVICE_USER@{device_ip} "$PROJECT/tests/lib/external/prepare-ssh.sh $HOST $PORT $DEVICE_USER"
    ssh $DEVICE_USER@{device_ip} './snappy-jenkins-jobs/scripts/utils/run_setup.sh {device_ip} $PORT $TEST_USER "$SETUP"'
    ssh $DEVICE_USER@{device_ip} './snappy-jenkins-jobs/scripts/utils/run_spread.sh $HOST $PORT $PROJECT "$SPREAD_TESTS"'
    scp $DEVICE_USER@{device_ip}:~/$PROJECT/report.xml artifacts/report.xml
EOF
