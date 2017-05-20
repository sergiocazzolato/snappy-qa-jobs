#!/bin/bash
set -e

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_QUEUE=$1
CHANNEL=$2
BRANCH=$3
SPREAD_TESTS=$4
SETUP=$5
SPREAD_ENV=$6

PROJECT=console-conf-tests
PROJECT_URL=https://github.com/sergiocazzolato/console-conf-tests.git
JOBS_URL=https://github.com/sergiocazzolato/snappy-jenkins-jobs.git

PORT=22
DEVICE_USER=ubuntu
TEST_USER=test

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  channel: $CHANNEL
test_data:
  test_cmds: |
    mkdir artifacts
    git clone $JOBS_URL
    git clone $PROJECT_URL
    cd $PROJECT && git checkout $BRANCH && cd ..
    $PROJECT/prepare-ssh.sh {device_ip} $PORT $DEVICE_USER
    ./snappy-jenkins-jobs/scripts/utils/run_setup.sh {device_ip} $PORT $TEST_USER $SETUP
    ./snappy-jenkins-jobs/scripts/utils/run_spread.sh {device_ip} $PORT $PROJECT $SPREAD_TESTS $SPREAD_ENV
    cp $PROJECT/report.xml artifacts/report.xml
EOF
