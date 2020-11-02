summary: Update actions runner for the service agents specified

prepare: |
    test -n "$ACTIONS_VERSION"
    test -n "$AGENT_PATH"

restore: |
	rm -rf actions-runner-linux-x64-*

execute: |
    # Download actions runner
	curl -O -L "https://github.com/actions/runner/releases/download/v${ACTIONS_VERSION}/actions-runner-linux-x64-${ACTIONS_VERSION}.tar.gz"

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
