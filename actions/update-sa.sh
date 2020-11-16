#!/bin/bash

# ssh to machine
# ssh ubuntu@<IP> -o IdentitiesOnly=yes -i <KEY_PATH>

# setup-machine
# SPREAD_EXTERNAL_ADDRESS=<IP> SPREAD_EXTERNAL_KEY=<KEY_PATH> spread2 -debug external:ubuntu-18.04-64-key:tasks/setup-machine

# setup-agent
# SPREAD_EXTERNAL_ADDRESS=<IP> SPREAD_AGENT_ID=<ID> SPREAD_GITHUB_TOKEN=<TOKEN> SPREAD_EXTERNAL_KEY=<KEY_PATH> spread2 -debug external:ubuntu-18.04-64-key:tasks/setup-agent

# check-agent-status / update-sa / update-spread
# SPREAD_EXTERNAL_ADDRESS=<IP> SPREAD_EXTERNAL_KEY=<KEY_PATH> spread2 -debug external:ubuntu-18.04-64-key:tasks/check-agent-status
set -ex

. variables.sh

instances=$(jq ". | length" $AGENTS)

for key in $(seq "$instances"); do
    echo "-------------------------------------------"
    iter=$(( $key - 1 ))
    jq ".[$iter].name" agents.json
    ip=$(jq -r ".[$iter].ip" $AGENTS)

    ssh -o IdentitiesOnly=yes -i $SPREAD_EXTERNAL_KEY $USER@$ip lxd.lxc list
    SPREAD_EXTERNAL_ADDRESS=$ip $SPREAD external:"$SYSTEM":tasks/update-service_account
done
