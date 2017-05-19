#!/bin/bash
set -e
echo "Running spread"

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_TESTS=$4

WORKSPACE=$(pwd)
SPREAD_URL=http://people.canonical.com/~sjcazzol/snappy/spread-amd64.tar.gz

# Get spread
wget $SPREAD_URL
tar xzvf spread-amd64.tar.gz
rm -f spread-amd64.tar.gz

cd $PROJECT_PATH
SPREAD_EXTERNAL_ADDRESS=$DEVICE_IP:$DEVICE_PORT $WORKSPACE/spread -v -xunit $SPREAD_TESTS
