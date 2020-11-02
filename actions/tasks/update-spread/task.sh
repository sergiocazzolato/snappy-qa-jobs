summary: Update spread for the service agents specified

prepare: |
    test -n "$(command -v go)"

restore: |
    rm -rf ~/go/bin/spread

execute: |
    # Update spread version
    go get -u github.com/snapcore/spread/cmd/spread

    if [ -z "$AGENT_ID" ]; then
        echo "Updating spread for all the agents"
        agents=$(lxd.lxc list --format csv | cut -d ',' -f1)
        
        for agent in $agents; do
            lxd.lxc file push ~/go/bin/spread "$agent"/tmp/spread-runner/spread
        done
    else
        agent="$AGENT_PREFIX-$AGENT_ID"
        lxd.lxc file push ~/go/bin/spread "$agent"/tmp/spread-runner/spread   
    fi
