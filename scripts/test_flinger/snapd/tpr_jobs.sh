#!/bin/bash

echo "Running tpr for snapd"

SNAPD_DIR=$WORKSPACE/snapd
if [ ! -d "$SNAPD_DIR/.git" ]; then
	rm -rf $SNAPD_DIR
	git clone $SNAPD_URL $SNAPD_DIR
fi

cd $WORKSPACE/snapd
git checkout $BRANCH

. $SCRIPTS_DIR/utils/run_tpr.sh