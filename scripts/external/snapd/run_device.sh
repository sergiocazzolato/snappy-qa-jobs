#!/bin/bash

git clone $SNAPD_URL $PROJECT
(cd $PROJECT && git reset --hard origin && git fetch origin && git checkout $BRANCH && git pull && git checkout $COMMIT)
$PRE_HOOK
. "$PROJECT/tests/lib/external/prepare-ssh.sh" "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER" || true
. "$SCRIPTS_DIR/utils/register_device.sh" "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER" "$DEVICE_PASS" "$REGISTER_EMAIL" || true
. "$SCRIPTS_DIR/utils/refresh.sh" "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER" "$DEVICE_PASS" "$CHANNEL" "$CORE_CHANNEL"
. "$SCRIPTS_DIR/utils/run_setup.sh" "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER" "$DEVICE_PASS" "$SETUP" || true
. "$SCRIPTS_DIR/utils/get_spread.sh"
. "$SCRIPTS_DIR/utils/run_spread.sh" "$DEVICE_IP" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" "$SPREAD_PARAMS"
$POST_HOOK
