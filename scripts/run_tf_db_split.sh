#!/bin/bash
set -ex

echo "Running test flinger script for dragonboard"

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPTS_DIR/env/tf_snapd_db_split.sh" ]; then
	. "$SCRIPTS_DIR/env/tf_snapd_db_split.sh"
else
	echo "Environment file does not exist: $SCRIPTS_DIR/env/tf_snapd_db_split.sh"
	exit 1
fi

echo "Deleting test flinger data"
sudo rm -f $TF_DATA/*

. "$SCRIPTS_DIR/utils/get_validator.sh"
. "$SCRIPTS_DIR/utils/get_spread.sh"
. "$SCRIPTS_DIR/test_flinger/$PROJECT/tpr_jobs.sh"
. "$SCRIPTS_DIR/test_flinger/run_jobs.sh"
