#!/bin/bash
set -e
echo "Running spread"

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_TESTS=$4
SPREAD_ENV=$5
LOG_FILE=results.log

# Export env variables
if [[ ! -z "$SPREAD_ENV" ]]; then
    export $SPREAD_ENV
fi
export SPREAD_EXTERNAL_ADDRESS=$DEVICE_IP:$DEVICE_PORT

echo "Running Spread with:"
echo "Variables: $SPREAD_ENV"
echo "Tests: $SPREAD_TESTS"

# Run spread
cd $PROJECT_PATH
rm -f $LOG_FILE
spread -v $SPREAD_TESTS | tee $LOG_FILE
