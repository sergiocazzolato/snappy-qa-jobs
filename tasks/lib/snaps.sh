#!/bin/bash

. "$TESTSLIB/systems.sh"

ensure_jq() {
    if command -v jq; then
        return
    fi

    if is_core18_system; then
        snap install --devmode jq-core18
        snap alias jq-core18.jq jq
    else
        snap install --devmode jq
    fi
}

remove_jq(){
	snap remove jq jq-core18
}

is_snap_installed(){
	local snap=$1

	if snap list "$snap"; then
		return 0
	fi
	return 1
}