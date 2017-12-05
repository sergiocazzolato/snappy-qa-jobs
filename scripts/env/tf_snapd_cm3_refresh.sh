#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export IMAGE_URL=${IMAGE_URL:-"http://cdimage.ubuntu.com/ubuntu-core/16/stable/current/ubuntu-core-16-cm3.img.xz"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"cm3"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32:tests/"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-""}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export SETUP=${SETUP:-""}
