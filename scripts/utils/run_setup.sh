#!/bin/bash
set -ex
echo "Running setup"

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

DEVICE_IP=$1
DEVICE_PORT=$2
USER=$3
SETUP=$4

echo "Setup command: $SETUP"
ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $DEVICE_PORT $USER@$DEVICE_IP "$SETUP"
