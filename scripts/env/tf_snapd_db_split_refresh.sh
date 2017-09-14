#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export CHANNEL_FROM=${CHANNEL_FROM:-"stable"}
export SKIP_TESTS=${SKIP_TESTS:-""}