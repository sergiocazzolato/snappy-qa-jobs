#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"dragonboard"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64:tests/"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-"tests/main/auto-refresh,tests/main/interfaces-content,tests/main/install-sideload,tests/main/snap-core-symlinks"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export SETUP=${SETUP:-""}
