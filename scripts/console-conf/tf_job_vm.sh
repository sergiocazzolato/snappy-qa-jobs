#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
SPREAD_SUITE=$4

PROJECT=console-conf-tests
PROJECT_URL=https://github.com/sergiocazzolato/console-conf-tests.git
JOBS_URL=https://github.com/sergiocazzolato/snappy-jenkins-jobs.git

if [ $ARCHITECTURE == "amd64" ]; then
    SPREAD_SYS=ubuntu-core-16-64
elif [ $ARCHITECTURE == "i386" ]; then
    SPREAD_SYS=ubuntu-core-16-32
else
    echo "Architecture $ARCHITECTURE not supported"
    exit 1
fi

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  distro: xenial
test_data:
  test_cmds: |
    mkdir artifacts
    ssh ubuntu@{device_ip} "git clone $JOBS_URL"
    ssh ubuntu@{device_ip} "./snappy-jenkins-jobs/scripts/utils/create_vm.sh $ARCHITECTURE $CHANNEL NO_PROXY 8022"
    ssh ubuntu@{device_ip} "git clone $PROJECT_URL"
    ssh ubuntu@{device_ip} "./snappy-jenkins-jobs/scripts/utils/run_spread.sh localhost 8022 $PROJECT $SPREAD_SYS $SPREAD_SUITE"
    scp ubuntu@{device_ip}:~/$PROJECT/report.xml artifacts/report.xml
EOF
