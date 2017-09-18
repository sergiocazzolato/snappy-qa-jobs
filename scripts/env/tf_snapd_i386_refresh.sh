#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export CORE_CHANNEL=${CORE_CHANNEL:-"stable"}
export ARCHITECTURE=${ARCHITECTURE:-"i386"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"amd-gfx"}
export CHANNEL=${CHANNEL:-"stable"}
export SETUP=${SETUP:-"sudo snap refresh --beta core"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-32"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-""}