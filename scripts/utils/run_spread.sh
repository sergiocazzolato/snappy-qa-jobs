#!/bin/bash
set -e

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_IP=$1
DEVICE_PORT=$2
PROJECT_PATH=$3
SPREAD_SYS=$4
SPREAD_SUITE=$5

WORKSPACE=$(pwd)
SPREAD_URL=http://people.canonical.com/~sjcazzol/snappy/spread-amd64.tar.gz

# Get spread
wget $SPREAD_URL
tar xzvf spread-amd64.tar.gz
rm -f spread-amd64.tar.gz

cd $PROJECT_PATH
SPREAD_EXTERNAL_ADDRESS=$DEVICE_IP:$DEVICE_PORT $WORKSPACE/spread -v -xunit external:$SPREAD_SYS:$SPREAD_SUITE
