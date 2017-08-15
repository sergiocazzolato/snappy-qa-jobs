#!/bin/bash
set -e
echo "Running spread"

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
fi

export WORKSPACE=${WORKSPACE:-$(pwd)}

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_TESTS=$4
SPREAD_ENV=$5

# Export env variables
if [[ ! -z "$SPREAD_ENV" ]]; then
    export $SPREAD_ENV
fi
export SPREAD_EXTERNAL_ADDRESS=$DEVICE_IP:$DEVICE_PORT

echo "Running Spread"
echo "Variables: $SPREAD_ENV"
echo "Tests: $SPREAD_TESTS"

if [[ $(which spread) ]]; then
    echo "Spread found"
else
    if [ -f $WORKSPACE/spread/spread ]; then
    	export PATH=$PATH:$WORKSPACE/spread
    else
    	echo "Spread not found"
    fi
fi

# Run spread
cd $PROJECT_PATH
spread -v $SPREAD_TESTS
