#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export DEVICE_QUEUE=${DEVICE_QUEUE:-"rpi3b"}

export ARCH=${ARCH:-"armhf"}
export CHANNEL=${CHANNEL:-"beta"}
export PROJECT=${PROJECT:-"snapd"}

export TEST_USER=${TEST_PASS:-"test"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}

export SPREAD_SETUP=${SPREAD_SETUP:-"external:ubuntu-core-16-arm-32:tasks/setup/"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32:tests/"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-""}
export SKIP_TESTS=${SKIP_TESTS:-""}