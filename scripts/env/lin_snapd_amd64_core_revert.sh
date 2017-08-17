#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export SPREAD_TESTS=${SPREAD_TESTS:-"linode:ubuntu-16.04-64:tests/nested/core-revert"}
export SPREAD_ENV=${SPREAD_ENV:-"SPREAD_CORE_CHANNEL=stable SPREAD_CORE_REFRESH_CHANNEL=beta"}
