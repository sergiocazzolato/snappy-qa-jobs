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
    local retries=$1
    local sleep=$2
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
    local retries=$1
    local sleep=$2
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
    local command=$1
    local output=$2
    local retries=$3
    local sleep=$4

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
    local command=$1
    local output=$2
    local retries=$3
    local sleep=$4

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
    local refresh_channel=$1
    local snap=$2

    wait_for_no_ssh 30 2
    wait_for_ssh 120 2
    retry_until "snap info $snap" "tracking: +${refresh_channel}" 10 2
}

do_full_refresh(){
    local channel=$1
    local core_channel=$2

    if [ -z "$core_channel" ]; then
        core_channel="$channel"
    fi
    wait_auto_refresh
    do_core_refresh "$core_channel"
    wait_auto_refresh
    do_snapd_refresh "$core_channel"
    wait_auto_refresh
    do_kernel_refresh "$channel"

    # Run update and make "|| true" to continue when the connection is closed by remote host or not any snap to update
    execute_remote "sudo snap refresh" || true
}

do_kernel_refresh(){
    local refresh_channel=$1

    local kernel_line=$(execute_remote "snap list | grep 'kernel$'")
    local kernel_name=$(echo $kernel_line | awk '{ print $1 }')

    if [ -z "$kernel_name" ]; then
        echo "No kernel snap to update"
        return
    fi

    output=$(execute_remote "sudo snap refresh --${refresh_channel} $kernel_name 2>&1" || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh \"$kernel_name\"|is not installed)"; then
        echo "snap \"$kernel_name\" has no updates available"
    else
        check_refresh "$refresh_channel" "$kernel_name"
    fi
}

do_snapd_refresh(){
    local refresh_channel=$1

    local snapd_line=$(execute_remote "snap list | grep 'snapd'")
    if [ -z "$snapd_line" ]; then
        echo "No snapd snap to update"
        return
    fi
    local snapd_name=$(echo $snapd_line | awk '{ print $1 }')

    # Run update and make "|| true" to continue when the connection is closed by remote host
    output=$(execute_remote "sudo snap refresh --${refresh_channel} $snapd_name 2>&1" || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh \"$snapd_name\"|is not installed)"; then
        echo "snap \"$snapd_name\" has no updates available"
    else
        check_refresh "$refresh_channel" "$snapd_name"
    fi
}

do_core_refresh(){
    local refresh_channel=$1

    local core_line=$(execute_remote "snap list | grep 'core18'")
    if [ -z "$core_line" ]; then
        core_line=$(execute_remote "snap list | grep 'core'")
    fi
    local core_name=$(echo $core_line | awk '{ print $1 }')

    # Run update and make "|| true" to continue when the connection is closed by remote host
    output=$(execute_remote "sudo snap refresh --${refresh_channel} $core_name 2>&1" || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh \"$core_name\"|is not installed)"; then
        echo "snap \"$core_name\" has no updates available"
    else
        check_refresh "$refresh_channel" "$core_name"
    fi
}

wait_auto_refresh(){
    # Wait in case auto-refresh is finished
    if execute_remote "snap changes" | grep -q -E "Doing.*Auto-refresh snap.*"; then
        echo "Auto-refresh in progress"
        retry_while "snap changes" "Doing.*Auto-refresh.*" 120 30
        wait_for_ssh 120 30
        retry_until "snap changes" "Done.*Auto-refresh.*" 120 4
        echo "Auto-refresh is completed"
    fi
}

check_install_snap(){
    local core18_line=$(execute_remote "snap list | grep 'core18'")
    local snap_name=jq-core18

    if [ -z "$core18_line" ]; then
        snap_name=jq
    fi
    # Retry until the core is ready to install a snap and remove it
    retry_until "sudo snap install --devmode $snap_name" "$snap_name .* installed" 20 10
    execute_remote "sudo snap remove $snap_name"
}

if [ "$SKIP_REFRESH" != "true" ]; then
    # Refresh core
    do_full_refresh "$CHANNEL" "$CORE_CHANNEL"
    check_install_snap
fi
