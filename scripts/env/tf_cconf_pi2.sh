#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"armhf"}
export CHANNEL=${CHANNEL:-"beta"}

export SKIP_REFRESH=${SKIP_REFRESH:-"true"}
export SPREAD_SETUP=${SPREAD_SETUP:-"testflinger:rpi2-16-beta:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export PROJECT=${PROJECT:-"console-conf-tests"}
export PROJECT_URL=$CCONF_URL
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_ENV=${SPREAD_ENV:-"WIFI_READY=false"}
