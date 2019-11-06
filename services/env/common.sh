#!/bin/bash
set -x

WORKSPACE=${1:-$(pwd)}

export SPREAD_LOG=$WORKSPACE/spread.log
export SUMMARY_LOG=$WORKSPACE/summary.log
export ATTACH_LOG=$WORKSPACE/attach.log