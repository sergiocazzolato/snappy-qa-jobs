#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export SPREAD_TESTS=${SPREAD_TESTS:-"google:ubuntu-16.04-64:tests/"}
export SPREAD_ENV=${SPREAD_ENV:-"REMOTE_STORE=staging SNAPPY_USE_STAGING_STORE=1"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
