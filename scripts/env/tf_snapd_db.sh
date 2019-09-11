#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"arm64"}
export CHANNEL=${CHANNEL:-"beta"}

export SPREAD_SETUP=${SPREAD_SETUP:-"testflinger:dragonboard-16-beta:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export PROJECT=${PROJECT:-"snapd"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64:tests/"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-""}



