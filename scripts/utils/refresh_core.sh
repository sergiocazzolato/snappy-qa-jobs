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
    retries=$1
    sleep=$2
    while ! execute_remote true; do
        retries=$(( retries - 1 ))
        if [ $retries -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            exit 1
        fi
        sleep $sleep
    done
}

retry_until(){
    command=$1
    output=$2
    retries=$3
    sleep=$4

    while ! execute_remote "$command" | grep -q -E "$output"; do
        retries=$(( retries - 1 ))
        if [ $retries -le 0 ]; then
            echo "Timed out reached. Aborting!"
            exit 1
        fi
        sleep $sleep
    done
}

retry_while(){
    command=$1
    output=$2
    retries=$3
    sleep=$4

    while execute_remote "$command" | grep -q -E "$output"; do
        retries=$(( retries - 1 ))
        if [ $retries -le 0 ]; then
            echo "Timed out reached. Aborting!"
            exit 1
        fi
        sleep $sleep
    done
}

# Auto-refresh core
if execute_remote "snap changes" | grep  -q -E "Doing.*Auto-refresh snap \"core\""; then
    echo "Auto-refresh for core in progress"
    retry_while "snap changes" "Doing.*Auto-refresh snap \"core\"" 120 30
    wait_for_ssh 120 30
    retry_until "snap changes" "Done.*Auto-refresh snap \"core\"" 120 2
    echo "Auto-refresh for core completed"
fi

# Refresh core
if [ -z "$CORE_CHANNEL" ]; then
    echo "No refresh channel defined, exiting"
elif [ "$CHANNEL" = "$CORE_CHANNEL" ]; then
    echo "No refresh channel needed"
else
    # Run update and make "|| true" to continue when the connection is closed by remote host
    execute_remote "sudo snap refresh --${CORE_CHANNEL} core" || true
    wait_for_ssh 120 2
    retry_until "snap changes" "Done.*Refresh \"core\" snap from \"${CORE_CHANNEL}\" channel" 120 2
    execute_remote "snap info core" | grep -q -E  "tracking: +${CORE_CHANNEL}"
fi
