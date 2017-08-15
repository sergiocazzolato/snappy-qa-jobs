#!/bin/bash
set -e

echo "Getting spread"

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SPREAD_DIR=$WORKSPACE/spread
export PATH=$SPREAD_DIR:$PATH

if [ -f $SPREAD_DIR/spread ]; then
	echo "Spread already downloaded"
else
	mkdir -p $SPREAD_DIR
	(cd "$SPREAD_DIR" && curl -s -O https://niemeyer.s3.amazonaws.com/spread-amd64.tar.gz && tar xzvf spread-amd64.tar.gz )	
fi

