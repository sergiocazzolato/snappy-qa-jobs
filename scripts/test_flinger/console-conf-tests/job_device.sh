#!/bin/bash

echo "Creating job for cconf using a device"

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
    channel: $CHANNEL
test_data:
    test_cmds: |
        #!/bin/bash
        sudo apt update || ps aux | grep apt
        sudo apt install -y git curl sshpass
        git clone $JOBS_URL
        (cd $JOBS_PROJECT && git checkout $JOBS_BRANCH)
        git clone $CCONF_URL
        (cd $PROJECT && git checkout $BRANCH)
        . $PROJECT/external/prepare_ssh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER"
        . $JOBS_PROJECT/scripts/utils/register_device.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$REGISTER_EMAIL"
        . $JOBS_PROJECT/scripts/utils/refresh_core.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$CORE_CHANNEL"
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$SETUP"
        . $JOBS_PROJECT/scripts/utils/get_spread.sh
        . $JOBS_PROJECT/scripts/utils/run_spread.sh "{device_ip}" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS"
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB
