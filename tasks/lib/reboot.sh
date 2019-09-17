#!/bin/bash

. "$TESTSLIB/journalctl.sh"


is_waiting_for_reboot(){
    if get_journalctl_log | grep "Waiting for system reboot"; then        
        return 0
    fi
    return 1
}

wait_for_reboot(){
	echo "Waiting for reboot"
    for _ in $(seq 150); do
        if check_journalctl_log "Waiting for system reboot"; then
             break
        fi
        sleep 5
    done
}
