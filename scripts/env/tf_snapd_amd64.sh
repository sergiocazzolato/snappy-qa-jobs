#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export ARCH=${ARCH:-"amd64"}
export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"beta"}
export CORE_CHANNEL=${CORE_CHANNEL:-"beta"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"maas-x86-node"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-64"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export SKIP_TESTS=${SKIP_TESTS:-"tests/core/snapd16,tests/core/snapd-failover,tests/core/core-to-snapd-failover16,tests/core/failover,tests/main/auto-refresh,tests/main/auto-refresh-retry,tests/main/interfaces-many-snap-provided,tests/main/interfaces-many-core-provided,tests/main/snap-model"}
