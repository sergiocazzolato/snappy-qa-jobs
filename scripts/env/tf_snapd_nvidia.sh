#!/bin/sh

. "$SCRIPTS_DIR/env/common.sh"

export PROJECT=${PROJECT:-"snapd"}
export CHANNEL=${CHANNEL:-"stable"}
export CORE_CHANNEL=${CORE_CHANNEL:-"stable"}
export DISTRO=${DISTRO:-"xenial"}
export DEVICE_QUEUE=${DEVICE_QUEUE:-"nvidia-gfx"}
export SPREAD_TESTS=${SPREAD_TESTS:-"external:ubuntu-16.04-64"}
export SPREAD_PARAMS=${SPREAD_PARAMS:-"-v"}
export TEST_PASS=${TEST_PASS:-"ubuntu"}
export TEST_USER_TYPE=${TEST_USER_TYPE:-"regular"}
export SKIP_TESTS=${SKIP_TESTS:-""}
export SETUP=${SETUP:-"sudo add-apt-repository -y ppa:graphics-drivers && sudo apt-get update && sudo apt-get install -y nvidia-390 && sudo reboot"}
export SETUP_2=${SETUP_2:-"echo 'Check nvidia is installed' && lsmod | grep nvidia"}
