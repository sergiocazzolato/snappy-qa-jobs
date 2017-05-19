#!/bin/bash
set -e
echo "Running setup"

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

DEVICE_IP=$1
DEVICE_PORT=$2
USER=$3
SETUP=$4

echo "Setup command: $SETUP"
ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $DEVICE_PORT $USER@$DEVICE_IP "$SETUP"
