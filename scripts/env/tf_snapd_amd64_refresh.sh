#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"amd64"}
export CHANNEL=${CHANNEL:-"stable"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}

export SPREAD_SETUP=${SPREAD_SETUP:-"testflinger:pc-amd64-16-refresh:tasks/setup/"}
export SPREAD_SETUP_PARAMS=${SPREAD_SETUP_PARAMS:-"-reuse"}

export PROJECT=${PROJECT:-"snapd"}
export PROJECT_URL=$SNAPD_URL
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-64:tests/"}
export SPREAD_TESTS_PARAMS=${SPREAD_TESTS_PARAMS:-""}
export SPREAD_TESTS_SKIP=${SPREAD_TESTS_SKIP:-"tests/main/auto-refresh,tests/main/auto-refresh-retry"}
