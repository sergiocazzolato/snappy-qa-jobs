#!/bin/bash

echo "Register device"

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters: $#"
    i=1
    for param in $*; do
        echo "param $i: $param"
        i=$(( i + 1 ))
    done
    exit 1
fi

DEVICE_IP=$1
DEVICE_PORT=$2
USER=$3
PASS=$4
EMAIL=$5

SCRIPT="sudo snap install jq; \
        sudo cp /var/lib/snapd/state.json /var/lib/snapd/state.json.bak; \
        sudo cat /var/lib/snapd/state.json.bak | jq -r '.data.auth.users=[]' | sudo tee /var/lib/snapd/state.json > /dev/null; \
        sudo systemctl stop snapd.service snapd.socket; \
        sudo systemctl start snapd.service snapd.socket; \
        sudo snap create-user $EMAIL; \
        sudo snap remove jq"

if [ -z "$EMAIL" ]; then
    echo "No email provided to make the registration"
elif [ -z "$PASS" ]; then
    echo "Registering device (no pass): $SCRIPT"
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $DEVICE_PORT $USER@$DEVICE_IP "$SCRIPT"
else
    echo "Registering device (with pass): $SCRIPT"
    sshpass -p $PASS ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $DEVICE_PORT $USER@$DEVICE_IP "$SCRIPT"
fi
