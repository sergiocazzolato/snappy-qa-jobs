#!/bin/bash
set -ex

if hostname | grep prod-snapd-testing; then
    . variables-prodstack.sh
else
    . variables-canonistack.sh
fi

instances=$(jq ". | length" $AGENTS)

for key in $(seq "$instances"); do
    echo "-------------------------------------------"
    iter=$(( $key - 1 ))
    jq ".[$iter].name" "$AGENTS"
    ip=$(jq -r ".[$iter].ip" $AGENTS)

    ( cd .. && SPREAD_EXTERNAL_ADDRESS=$ip "$SPREAD" external:"$SYSTEM":tasks/update-agents )
done

