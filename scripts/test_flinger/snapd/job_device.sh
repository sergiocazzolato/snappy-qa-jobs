#!/bin/bash

echo "Creating job for snapd using a device"

if [ -z $IMAGE_URL ]; then
    PROVISION_METHOD="channel"
    PROVISION_VAR="$CHANNEL"
else
    PROVISION_METHOD="url"
    PROVISION_VAR="$IMAGE_URL"
fi

. "$SCRIPTS_DIR/utils/snap_info.sh"
sudo apt install -y jq
if [ "$BRANCH" = beta ]; then
    BRANCH=$(get_beta_branch "$ARCH")
elif [ "$BRANCH" = edge ]; then
    BRANCH=$(get_edge_commit "$ARCH")
fi

cat > job.yaml <<EOF
job_queue: $DEVICE_QUEUE
global_timeout: 36000
provision_data:
    $PROVISION_METHOD: $PROVISION_VAR
test_data:
    test_cmds: |
        #!/bin/bash
        sudo apt update || ps aux | grep apt
        sudo apt install -y git curl sshpass jq
        git clone $JOBS_URL
        (cd $JOBS_PROJECT && git checkout $JOBS_BRANCH)
        git clone $SNAPD_URL $PROJECT
        (cd $PROJECT && git checkout $BRANCH && git checkout $COMMIT)
        . $JOBS_PROJECT/scripts/utils/add_test_user.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER"
        . $JOBS_PROJECT/scripts/utils/register_device.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$REGISTER_EMAIL" || true
        . $JOBS_PROJECT/scripts/utils/refresh.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$CHANNEL" "$CORE_CHANNEL"
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "{device_ip}" "$DEVICE_PORT" "$TEST_USER" "$TEST_PASS" "$SETUP" || true
        . $JOBS_PROJECT/scripts/utils/get_spread.sh
        . $JOBS_PROJECT/scripts/utils/run_spread.sh "{device_ip}" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" "$SPREAD_PARAMS"
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB
