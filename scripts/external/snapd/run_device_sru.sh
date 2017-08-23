#!/bin/bash

git clone $SNAPD_URL
(cd $PROJECT && git fetch origin && git checkout $BRANCH && git pull)
. "$SCRIPTS_DIR/utils/run_setup.sh" "$DEVICE_IP" "$DEVICE_PORT" "$DEVICE_USER" "$DEVICE_PASS" "$SETUP" || true
