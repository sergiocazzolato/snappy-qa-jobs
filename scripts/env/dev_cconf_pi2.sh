#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"console-conf-tests"}
export CHANNEL=${CHANNEL:-"beta"}
export BRANCH=${BRANCH:-"master"}
export SETUP=${SETUP:-""}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-32"}
export SPREAD_ENV=${SPREAD_ENV:-""}