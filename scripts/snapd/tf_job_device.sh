#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
SPREAD_SUITE=$4

PROJECT=snapd
PROJECT_URL=https://github.com/snapcore/snapd.git
JOBS_URL=https://github.com/sergiocazzolato/snappy-jenkins-jobs.git

if [ $ARCHITECTURE == "arm64" ]; then
    SPREAD_SYS=ubuntu-core-16-arm-64
elif [ $ARCHITECTURE == "arm32" ]; then
    SPREAD_SYS=ubuntu-core-16-arm-32
else
    echo "Architecture $ARCHITECTURE not supported"
    exit 1
fi

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  channel: $CHANNEL
test_data:
  test_cmds: |
    mkdir artifacts
    ssh ubuntu@{device_ip} 'sudo adduser --extrausers --quiet --disabled-password --gecos "" test'
    ssh ubuntu@{device_ip} 'echo test:ubuntu | sudo chpasswd'
    ssh ubuntu@{device_ip} 'echo "test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/create-user-test'
    git clone $JOBS_URL
    git clone $PROJECT_URL
    ./snappy-jenkins-jobs/scripts/utils/run_spread.sh {device_ip} 22 $PROJECT $SPREAD_SYS $SPREAD_SUITE
    scp ubuntu@{device_ip}:~/$PROJECT/report.xml artifacts/report.xml
  test_username: admin
  test_password: admin
EOF
