#!/bin/bash

is_user_created(){
    local user=$1
    if id $user >/dev/null 2>&1; then
        return 0
    fi
    return 1
}
