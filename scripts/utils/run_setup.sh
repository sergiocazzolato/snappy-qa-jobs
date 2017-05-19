#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_IP=$1
DEVICE_PORT=$2
USER=$3
SETUP=$4

ssh -p $DEVICE_PORT $USER@$DEVICE_IP "$SETUP"
