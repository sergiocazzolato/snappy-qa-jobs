#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export DEVICE_IP=${DEVICE_IP:-"127.0.0.1"}
export SETUP=${SETUP:-"sudo rm -rf /home/gopath"}