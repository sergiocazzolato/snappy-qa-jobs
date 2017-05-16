#!/bin/bash
set -ex

DEVICE_QUEUE=$1
CHANNEL=$2
SPREAD_SYS=$3
SPREAD_SUITE=$4

SNAPD_URL=https://github.com/snapcore/snapd
SPREAD_URL=http://people.canonical.com/~sjcazzol/snappy/spread-amd64.tar.gz

WORKSPACE=$(pwd)
RESULTS=$WORKSPACE/results
mkdir $RESULTS

JOB_DATA=/var/snap/testflinger-cli/current
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
    git clone $SNAPD_URL
    wget $SPREAD_URL
    tar xzvf spread-amd64.tar.gz
    cd snapd
    SPREAD_EXTERNAL_ADDRESS={device_ip} ../spread -v -xunit external:$SPREAD_SYS:$SPREAD_SUITE
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
