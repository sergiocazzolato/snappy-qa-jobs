#!/bin/bash

echo "Refresh core on device"

if [ "$#" -ne 6 ]; then
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
CHANNEL=$5
CORE_CHANNEL=$6

execute_remote(){
    if [ -z "$PASS" ]; then
        ssh -p $DEVICE_PORT -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$DEVICE_IP "$*"
    else
        sshpass -p $PASS ssh -p $DEVICE_PORT -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$DEVICE_IP "$*"
    fi    
}

wait_for_ssh(){
    retry=120
    while ! execute_remote true; do
        retry=$(( retry - 1 ))
        if [ $retry -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            exit 1
        fi
        sleep 1
    done
}

if [ -z "$CORE_CHANNEL" ]; then
    echo "No refresh channel defined, exiting"
elif [ "$CHANNEL" = "$CORE_CHANNEL" ]; then
    echo "No refresh channel needed"
else
    execute_remote "sudo snap refresh --${CORE_CHANNEL} core" || exit
    wait_for_ssh
    while ! execute_remote "snap changes" | grep -q -E "Done.*Refresh \"core\" snap from \"${CORE_CHANNEL}\" channel"; do
        sleep 1
    done
    execute_remote "snap info core" | grep -q -E  "tracking: +${CORE_CHANNEL}"
fi
