#!/bin/bash
set -e

export SPREAD_DIR=$WORSKPACE/spread
export PATH=$SPREAD_DIR:$PATH

if [ -d $SPREAD_DIR ]; then
	exit
fi

mkdir -p $SPREAD_DIR
(cd "$SPREAD_DIR" && curl -s -O https://niemeyer.s3.amazonaws.com/spread-amd64.tar.gz && tar xzvf spread-amd64.tar.gz )
