#!/bin/bash
set -ex

if hostname | grep prod-snapd-testing; then
    . variables-prodstack.sh
else
    . variables-canonistack.sh
fi

target_project=${1:-}
sa_file=${2:-}
if [ -z "$target_project" ]; then
	echo "project missing as parameter, exiting..."
	exit
fi
if [ -z "$sa_file" ]; then
	echo "service acount file missing as parameter, exiting..."
	exit
fi

instances=$(jq ". | length" $AGENTS)

for key in $(seq "$instances"); do
    echo "-------------------------------------------"
    iter=$(( $key - 1 ))
    jq ".[$iter].name" "$AGENTS"
    ip=$(jq -r ".[$iter].ip" $AGENTS)
    curr_project=$(jq -r ".[$iter].project" $AGENTS)

    if [ "$target_project" = "$curr_project" ]; then
    	ssh -o IdentitiesOnly=yes -i $SPREAD_EXTERNAL_KEY $USER@$ip sudo lxd.lxc list
    	SPREAD_EXTERNAL_ADDRESS=$ip SPREAD_SA_FILE="$sa_file" "$SPREAD" external:"$SYSTEM":tasks/update-service-account
    else
    	echo "Skipping service account configuration for project $curr_project"
    fi
done

