#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"i386"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export CORE_CHANNEL=${CORE_CHANNEL:-"stable"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"maas-x86-node"}
export DEVICE_DISTRO=${DEVICE_DISTRO:-"focal"}
export CHANNEL=${CHANNEL:-"stable"}
export SNAPD_CHANNEL=${SNAPD_CHANNEL:-"beta"}
export SETUP=${SETUP:-""}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-20-32"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-""}
