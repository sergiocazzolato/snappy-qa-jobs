#!/bin/bash
set -ex
DEVICE_QUEUE=$1
ARCHITECTURE=$2
CHANNEL=$3
SPREAD_SUITE=$4

WORKSPACE=$(pwd)

mkdir $WORKSPACE/results
cat > job.json <<EOF
{
    "job_queue": "$DEVICE_QUEUE",
    "provision_data": {
        "distro": "xenial"
    },
     "test_data": {
        "test_cmds": [
            "HTTPS_PROXY=https://squid.internal:3128 git clone snappy-jenkins-jobs",
            "mkdir artifacts",
            "ssh ubuntu@{device_ip} 'HTTPS_PROXY=https://squid.internal:3128 git clone https://github.com/sergiocazzolato/snappy-jenkins-jobs.git'",
            "ssh ubuntu@{device_ip} \'./snappy-jenkins-jobs/scripts/snapd/run_spread_vm.sh $ARCHITECTURE $CHANNEL $SPREAD_SUITE\'",
            "scp ubuntu@{device_ip} report.xml artifacts/"
        ]
    }
}
EOF

