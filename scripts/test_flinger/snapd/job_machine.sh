#!/bin/bash

echo "Creating job for snapd using a device"

if ! [ -z $IMAGE_URL ]; then
    PROVISION_METHOD="url"
    PROVISION_VAR="$IMAGE_URL"
elif ! [ -z $DISTRO ]; then
    PROVISION_METHOD="distro"
    PROVISION_VAR="$DISTRO"
else
    PROVISION_METHOD="channel"
    PROVISION_VAR="$CHANNEL"
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
        sudo apt install -y git curl sshpass
        git clone $JOBS_URL
        (cd $JOBS_PROJECT && git checkout $JOBS_BRANCH)
        git clone $SNAPD_URL $PROJECT
        (cd $PROJECT && git checkout $BRANCH)
        . $JOBS_PROJECT/scripts/utils/add_test_user.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER" "generic" "ubuntu" "$TEST_USER_TYPE"
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER" "" "$SETUP" || true
        $POST_SETUP
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER" "" "$SETUP_2" || true
        $POST_SETUP_2
        . $JOBS_PROJECT/scripts/utils/run_setup.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER" "" "$SETUP_3" || true
        . $JOBS_PROJECT/scripts/utils/refresh_core.sh "{device_ip}" "$DEVICE_PORT" "$DEVICE_USER" "" "$CHANNEL" "$CORE_CHANNEL" || true
        . $JOBS_PROJECT/scripts/utils/get_spread.sh
        . $JOBS_PROJECT/scripts/utils/run_spread.sh "{device_ip}" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" "$SPREAD_PARAMS"
EOF

export TF_JOB=$TF_DATA/job.yaml
sudo mv job.yaml $TF_JOB
