#!/bin/bash

echo "Running spread"

if [ "$#" -ne 6 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

export WORKSPACE=${WORKSPACE:-$(pwd)}

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_TESTS=$4
SPREAD_ENV=$5
SKIP_TESTS=$6

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

if [[ $(which spread) ]]; then
    echo "Spread found"
else
    if [ -f "$WORKSPACE/spread/spread" ]; then
    	export PATH=$PATH:$WORKSPACE/spread
    else
    	echo "Spread not found"
    fi
fi

# Run spread
cd $PROJECT_PATH

echo "Moving to manual all the tests to skip: $SKIP_TESTS"
for test in $SKIP_TESTS; do
    if [ -f $test/task.yaml ]; then
        cp $test/task.yaml $test/task.yaml.back
        echo "manual: true" >> $test/task.yaml
    fi
done

echo "Running command: spread -v $SPREAD_TESTS"
spread -v $SPREAD_TESTS

echo "Restoring skipped tests"
for test in $SKIP_TESTS; do
    if [ -f $test/task.yaml.back ]; then
        mv $test/task.yaml.back $test/task.yaml
    fi
done
