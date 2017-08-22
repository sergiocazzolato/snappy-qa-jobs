#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export SPREAD_TESTS=${SPREAD_TESTS:-"linode:ubuntu-14.04-64 linode:ubuntu-16.04-64 linode:ubuntu-16.10-64 linode:ubuntu-17.04-64"}
export SPREAD_ENV=${SPREAD_ENV:-"SPREAD_MODIFY_CORE_SNAP_FOR_REEXEC=0 SPREAD_TRUST_TEST_KEYS=false SPREAD_SNAP_REEXEC=0 SPREAD_CORE_CHANNEL=beta"}
