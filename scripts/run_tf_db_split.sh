#!/bin/bash
set -e

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPTS_DIR/env/tf_snapd_db_split.sh" ]; then 
	. "$SCRIPTS_DIR/env/tf_snapd_db_split.sh"
else
	echo "Environment file does not exist: $SCRIPTS_DIR/env/tf_snapd_db_split.sh"
	exit 1
fi

rm -f $TF_DATA/*

. "$SCRIPTS_DIR/utils/get_validator.sh"
. "$SCRIPTS_DIR/utils/run_tpr.sh"
. "$SCRIPTS_DIR/test_flinger/run_jobs.sh"
