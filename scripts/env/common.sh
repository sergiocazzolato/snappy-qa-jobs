#!/bin/sh

export JOBS_PROJECT=${JOBS_PROJECT:-"snappy-qa-jobs"}
export JOBS_URL=${JOBS_URL:-"https://github.com/sergiocazzolato/snappy-qa-jobs.git"}
export JOBS_BRANCH=${JOBS_BRANCH:-"master"}
export SNAPD_URL=${SNAPD_URL:-"https://github.com/snapcore/snapd.git"}
export CCONF_URL=${CCONF_URL:-"https://github.com/sergiocazzolato/console-conf-tests.git"}
export TF_CLIENT=${TF_CLIENT:-"/snap/bin/testflinger-cli"}
export TF_DATA=${TF_DATA:-"/var/snap/testflinger-cli/current"}
export GOPATH=$WORKSPACE/gopath

export DEVICE_USER=${DEVICE_USER:-"ubuntu"}
export DEVICE_PASS=${DEVICE_PASS:-""}
export DEVICE_PORT=${DEVICE_PORT:-22}
export TEST_USER=${TEST_USER:-"test"}

export BRANCH=${BRANCH:-"master"}
export COMMIT=${COMMIT:-"HEAD"}

export SPREAD_URL=${SPREAD_URL:-"https://cachio.s3.amazonaws.com/spread/spread2"}
export SPREAD_BIN=${SPREAD_BIN:-"spread2"}