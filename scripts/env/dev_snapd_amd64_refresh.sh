#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export SETUP=${SETUP:-""}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-64"}
export DEVICE_IP=${DEVICE_IP:-"127.0.0.1"}