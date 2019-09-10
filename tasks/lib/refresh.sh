#!/bin/bash

. "$TESTSLIB/reboot.sh"
. "$TESTSLIB/snaps.sh"
. "$TESTSLIB/systems.sh"

wait_auto_refresh(){
    # Wait in case auto-refresh is finished
    if snap changes | MATCH "Doing.*Auto-refresh snap.*"; then
        wait_for_reboot
    fi
}

disable_refreshes() {
    echo "Ensure jq is available"
    ensure_jq

    echo "Modify state to make it look like the last refresh just happened"
    systemctl stop snapd.socket snapd.service
    jq ".data[\"last-refresh\"] = \"$(date +%Y-%m-%dT%H:%M:%S%:z)\"" /var/lib/snapd/state.json > /var/lib/snapd/state.json.new
    mv /var/lib/snapd/state.json.new /var/lib/snapd/state.json
    systemctl start snapd.socket snapd.service

    echo "Minimize risk of hitting refresh schedule"
    snap set core refresh.schedule=00:00-23:59
    snap refresh --time --abs-time | MATCH "last: 2[0-9]{3}"

    echo "Ensure jq is gone"
    remove_jq
}

do_core_refresh(){
    local refresh_channel=$1

    local core_name=core
    if is_core18_system; then
        core_name=core18
    fi

    # Run update and make "|| true" to continue when the connection is closed by remote host
    output=$(snap refresh --"$refresh_channel" "$core_name" 2>&1 || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh \"$core_name\"|is not installed)"; then
        echo "snap \"$core_name\" has no updates available"
    else
        wait_for_reboot
    fi
}

do_kernel_refresh(){
    local refresh_channel=$1

    local kernel_line=$(execute_remote "snap list | grep 'kernel$'")
    local kernel_name=$(echo $kernel_line | awk '{ print $1 }')

    if [ -z "$kernel_name" ]; then
        echo "No kernel snap to update"
        return
    fi

    output=$(snap refresh --"$refresh_channel" "$kernel_name" 2>&1 || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh \"$kernel_name\"|is not installed)"; then
        echo "snap \"$kernel_name\" has no updates available"
    else
        wait_for_reboot
    fi
}

do_snapd_refresh(){
    local refresh_channel=$1

    # Run update and make "|| true" to continue when the connection is closed by remote host
    output=$(snap refresh --"$refresh_channel" snapd 2>&1 || true)
    if echo "$output" | grep -E "(no updates available|cannot refresh snpad|is not installed)"; then
        echo "snapd snap has no updates available"
    fi
}
