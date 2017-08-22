#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"console-conf-tests"}
export CHANNEL=${CHANNEL:-"beta"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-core-16-arm-64"}
export WIFI_SSID=${WIFI_SSID:-""}
export WIFI_PASSWORD=${WIFI_PASSWORD:-""}
export DEVICE_IP=${DEVICE_IP:-"127.0.0.1"}
