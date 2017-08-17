#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export SETUP=${SETUP:-"sudo snap refresh --beta core"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-32"}
export DEVICE_IP=${DEVICE_IP:-"127.0.0.1"}