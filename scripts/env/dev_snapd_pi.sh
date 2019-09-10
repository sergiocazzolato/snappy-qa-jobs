#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"armhf"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32"}
export SPREAD_SETUP=${SPREAD_SETUP:-"external:ubuntu-core-16-arm-32-cert:tasks/setup/"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-""}
export DEVICE_IP=${DEVICE_IP:-"127.0.0.1"}
export SETUP_SCRIPT=${SETUP_SCRIPT:-"sudo rm -rf /home/gopath"}