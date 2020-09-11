#!/bin/bash

echo "Creating job for cconf using a device"

if [ -z "$IMAGE_URL" ]; then
    PROVISION_METHOD="channel"
    PROVISION_VAR="$CHANNEL"
else
    PROVISION_METHOD="url"
    PROVISION_VAR="$IMAGE_URL"
fi

DEVICE_IP='$DEVICE_IP'

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
provision_data:
    $PROVISION_METHOD: $PROVISION_VAR
test_data:
    test_cmds: |
        #!/bin/bash
        sudo apt update || ps aux | grep apt
        sudo apt install -y git curl sshpass jq unzip
        git clone $JOBS_URL
        (cd $JOBS_PROJECT && git checkout $JOBS_BRANCH)
        "$JOBS_PROJECT/scripts/utils/get_project.sh" "$CCONF_URL" "$PROJECT" "$BRANCH" ""
        $PRE_HOOK
        . $PROJECT/external/prepare_ssh "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER"
        . $JOBS_PROJECT/scripts/utils/add_root_key.sh "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER"
        . $JOBS_PROJECT/scripts/utils/refresh.sh "$DEVICE_IP" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$CHANNEL" "$CORE_CHANNEL" "$SNAPD_CHANNEL"
        . $JOBS_PROJECT/scripts/utils/register_device.sh "$DEVICE_IP" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$REGISTER_EMAIL"
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "$DEVICE_IP" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$SETUP"
        . $JOBS_PROJECT/scripts/utils/get_spread.sh "$SPREAD_URL"
        . $JOBS_PROJECT/scripts/utils/run_spread.sh "$DEVICE_IP" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" "$SPREAD_PARAMS"
        $POST_HOOK
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB
