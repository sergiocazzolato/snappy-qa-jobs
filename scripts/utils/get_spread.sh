#!/bin/bash

echo "Getting spread"

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SPREAD_DIR=$WORKSPACE/spread
export PATH=$SPREAD_DIR:$PATH

if [ -f "$SPREAD_DIR/$SPREAD_BIN" ]; then
    echo "Spread already downloaded"
else
    mkdir -p "$SPREAD_DIR"
    (cd "$SPREAD_DIR" && curl -s -O "$SPREAD_URL" )	
    echo "Spread downloaded and ready to use"
fi

chmod +x "$SPREAD_DIR/$SPREAD_BIN"
