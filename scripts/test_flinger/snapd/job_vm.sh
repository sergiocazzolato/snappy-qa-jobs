#!/bin/bash
set -e

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
fi

HOST=localhost
PORT=8022
DEVICE_USER=ubuntu
TEST_USER=test

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  distro: xenial
test_data:
    test_cmds:
        - ssh $DEVICE_USER@{device_ip} "sudo apt update && sudo apt install -y git curl"
        - ssh $DEVICE_USER@{device_ip} "git clone $JOBS_URL"        
        - ssh $DEVICE_USER@{device_ip} "git clone $VALIDATOR_URL"
        - ssh $DEVICE_USER@{device_ip} "git clone $PROJECT_URL"
        - ssh $DEVICE_USER@{device_ip} "$JOBS_PROJECT/scripts/utils/create_vm.sh $ARCHITECTURE $CHANNEL $PORT"
        - ssh $DEVICE_USER@{device_ip} "(cd $PROJECT && git checkout $BRANCH && cd ..)"
        - ssh $DEVICE_USER@{device_ip} "$JOBS_PROJECT/scripts/utils/run_setup.sh {device_ip} $PORT $TEST_USER \"$SETUP\" "
        - ssh $DEVICE_USER@{device_ip} "$JOBS_PROJECT/scripts/utils/run_spread.sh $HOST $PORT $PROJECT \"$SPREAD_TESTS\" \"$SPREAD_ENV\" "
EOF
