#!/bin/sh

export JOBS_PROJECT=snappy-qa-jobs
export JOBS_URL=https://github.com/sergiocazzolato/snappy-qa-jobs.git
export JOBS_BRANCH=automate-beta-validation
export SNAPD_URL=https://github.com/snapcore/snapd.git
export CCONF_URL=https://github.com/sergiocazzolato/console-conf-tests.git
export TPR_URL=github.com/sergiocazzolato/validator/cmd/tpr
export VALIDATOR_URL=https://github.com/sergiocazzolato/validator.git
export TF_CLIENT=/snap/bin/testflinger-cli
export TF_DATA=/var/snap/testflinger-cli/current
export GOPATH=$WORKSPACE/gopath

export DEVICE_USER=${DEVICE_USER:-"ubuntu"}
export DEVICE_PORT=${DEVICE_PORT:-22}
export TEST_USER=${TEST_USER:-"test"}