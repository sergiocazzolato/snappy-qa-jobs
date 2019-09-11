#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"arm64"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"dragonboard"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-18-arm-64:tests/"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-""}

#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"arm64"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}

export SPREAD_SETUP=${SPREAD_SETUP:-"testflinger:dragonboard-16-beta:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64:tests/"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-""}