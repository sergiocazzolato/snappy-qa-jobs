#!/bin/bash

echo "Running tests on test flinger dragonboards"

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
else
	. "$SCRIPTS_DIR/utils/load_env.sh" "$1"
fi

echo "Deleting test flinger data"
sudo rm -f $TF_DATA/*

. "$SCRIPTS_DIR/utils/get_validator.sh"
. "$SCRIPTS_DIR/utils/get_spread.sh"
. "$SCRIPTS_DIR/test_flinger/$PROJECT/tpr_jobs.sh"
. "$SCRIPTS_DIR/test_flinger/run_jobs.sh"
