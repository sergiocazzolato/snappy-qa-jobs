#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
SPREAD_SUITE=$4

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
  distro: xenial
test_data:
  test_cmds: |
    mkdir artifacts
    ssh ubuntu@{device_ip} 'sudo adduser --extrausers --quiet --disabled-password --gecos "" test'
	ssh ubuntu@{device_ip} 'echo test:ubuntu | sudo chpasswd'
	ssh ubuntu@{device_ip} 'echo "test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/create-user-test'
    git clone https://github.com/sergiocazzolato/snappy-jenkins-jobs.git
    git clone https://github.com/snapcore/snapd
    ./snappy-jenkins-jobs/scripts/utils/run_spread.sh {device_ip} 22 snapd $SPREAD_SYS $SPREAD_SUITE
    scp ubuntu@{device_ip}:~/snapd/report.xml artifacts/report.xml
  test_username: admin
  test_password: admin
EOF
