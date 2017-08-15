#!/bin/sh
set -e

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export BRANCH=${BRANCH:-"release/2.27"}
export SETUP=${SETUP:-""}
export SPREAD_ENV=${SPREAD_ENV:-""}