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
        ssh -p $DEVICE_PORT -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$DEVICE_IP "$*"
    else
        sshpass -p $PASS ssh -p $DEVICE_PORT -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$DEVICE_IP "$*"
    fi    
}

wait_for_ssh(){
    retries=$1
    sleep=$2
    while ! execute_remote true; do
        retries=$(( retries - 1 ))
        if [ $retries -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            break
        fi
        sleep $sleep
    done
}

wait_for_no_ssh(){
    retries=$1
    sleep=$2
    while execute_remote true; do
        retries=$(( retries - 1 ))
        if [ $retries -le 0 ]; then
            echo "Timed out waiting for no ssh. Aborting!"
            break
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

check_refresh(){
    refresh_channel=$1

    wait_for_no_ssh 30 2
    wait_for_ssh 120 2
    retry_until "snap info core" "tracking: +${refresh_channel}" 10 2
}

do_full_refresh(){
    refresh_channel=$1

    # Run update and make "|| true" to continue when the connection is closed by remote host
    execute_remote "sudo snap refresh" || true
    check_refresh "$refresh_channel"
}

do_core_refresh(){
    refresh_channel=$1

    # Run update and make "|| true" to continue when the connection is closed by remote host
    execute_remote "sudo snap refresh --${refresh_channel} core" || true
    check_refresh "$refresh_channel"
}

# Wait in case auto-refresh is finished
if execute_remote "snap changes" | grep -q -E "Doing.*Auto-refresh snap.*"; then
    echo "Auto-refresh in progress"
    retry_while "snap changes" "Doing.*Auto-refresh.*" 120 30
    wait_for_ssh 120 30
    retry_until "snap changes" "Done.*Auto-refresh.*" 120 4
    echo "Auto-refresh is completed"
fi

# Refresh core
if [ -z "$CORE_CHANNEL" ]; then
    echo "No refresh channel defined, exiting"
    return
elif [ "$CHANNEL" = "$CORE_CHANNEL" ]; then
    do_full_refresh "$CHANNEL"
else
    do_core_refresh "$CORE_CHANNEL" "core"
fi

# Retry until the core is ready to install a snap and remove it
retry_until "sudo snap install --devmode jq" "jq .* installed" 20 10
execute_remote "sudo snap remove jq"
