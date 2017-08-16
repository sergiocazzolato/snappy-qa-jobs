#!/bin/sh
set -ex

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export ARCHITECTURE=${ARCHITECTURE:-"amd64"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"intel-gfx"}
export CHANNEL=${CHANNEL:-"beta"}
export BRANCH=${BRANCH:-"master"}
export SETUP=${SETUP:-""}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-16.04-64:tests/nested/core-revert"}
export SPREAD_ENV=${SPREAD_ENV:-"SPREAD_CORE_CHANNEL=stable SPREAD_CORE_REFRESH_CHANNEL=beta"}
