#!/bin/bash
set -e

DEVICE_PORT=22
DEVICE_USER=ubuntu
TEST_USER=test

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
  channel: $CHANNEL
test_data:
  	test_cmds:
	  	- sudo apt update && sudo apt install -y git curl
	    - git clone $JOBS_URL
	    - git clone $PROJECT_URL
	    - (cd $PROJECT && git checkout $BRANCH && cd ..)
	    - . "$PROJECT/tests/lib/external/prepare-ssh.sh" {device_ip} $DEVICE_PORT $DEVICE_USER
	    - . "$JOBS_PROJECT/scripts/utils/run_setup.sh" {device_ip} $DEVICE_PORT $TEST_USER $SETUP
	    - . "$JOBS_PROJECT/scripts/utils/get_spread.sh"
	    - . "$JOBS_PROJECT/scripts/utils/run_spread.sh" {device_ip} $DEVICE_PORT $PROJECT $SPREAD_TESTS $SPREAD_ENV
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB