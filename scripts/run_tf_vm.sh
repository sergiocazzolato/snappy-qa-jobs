#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi

export WORKSPACE=${WORKSPACE:-$(pwd)}
export SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPTS_DIR/env/$1.sh" ]; then
	. "$SCRIPTS_DIR/env/$1.sh"
else
	echo "Environment file does not exist: $SCRIPTS_DIR/env/$1.sh"
	exit 1
fi

sudo rm -f $TF_DATA/*

. "$SCRIPTS_DIR/test_flinger/$PROJECT/job_vm.sh"
. "$SCRIPTS_DIR/test_flinger/run_job.sh"