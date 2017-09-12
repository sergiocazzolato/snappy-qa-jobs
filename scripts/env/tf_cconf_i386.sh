#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"console-conf-tests"}
export CHANNEL=${CHANNEL:-"beta"}
export ARCHITECTURE=${ARCHITECTURE:-"i386"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"intel-gfx"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-32"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
