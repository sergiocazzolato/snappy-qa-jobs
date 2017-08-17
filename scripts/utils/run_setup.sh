#!/bin/bash

echo "Running setup command"

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

DEVICE_IP=$1
DEVICE_PORT=$2
USER=$3
SETUP=$4

if [ -z "$SETUP" ]; then
	echo "No setup command to run"
else
	echo "Running setup command: $SETUP"
	ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $DEVICE_PORT $USER@$DEVICE_IP "$SETUP"
fi
