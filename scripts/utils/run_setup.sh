#!/bin/bash
set -ex

echo "Running spread"

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters: $#"
    i=1
    for param in $*; do
        echo "param $i: $param"
        i=$(( i + 1 ))
    done
    exit 1
fi

export WORKSPACE=${WORKSPACE:-$(pwd)}

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_TESTS=$4
SPREAD_ENV=$5
SPREAD_PARAMS=$7

if [ -z "$SPREAD_TESTS" ]; then
    echo "Spread tests not defined, skipping execution"
    exit
fi

# Export env variables
if [ ! -z "$SPREAD_ENV" ]; then
    echo "Using spread env: $SPREAD_ENV"
    export $SPREAD_ENV
fi
export SPREAD_EXTERNAL_ADDRESS=$DEVICE_IP:$DEVICE_PORT

if command -v "$SPREAD_BIN"; then
    echo "Spread found"
else
    if [ -f "$WORKSPACE/spread/$SPREAD_BIN" ]; then
        export PATH="$PATH:$WORKSPACE/spread/$SPREAD_BIN"
    else
        echo "Spread not found"
    fi
fi

spread_params="$(echo $SPREAD_SETUP_PARAMS | tr ',' ' ')"
spread_tests="$(echo $SPREAD_SETUP | tr ',' ' ')"

# Run spread
echo "Running command: spread $spread_params $spread_tests"
( cd "$PROJECT_DIR" && $SPREAD_BIN $spread_params $spread_tests )
