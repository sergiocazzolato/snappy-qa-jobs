#!/bin/bash

git clone "$PROJECT_URL" "$PROJECT"

. "$SCRIPTS_DIR/utils/snap_info.sh"
if [ "$BRANCH" = beta ]; then
	BRANCH=$(get_beta_branch "$ARCH")
elif [ "$BRANCH" = edge ]; then
	BRANCH=$(get_edge_commit "$ARCH")
fi

(cd $PROJECT && git reset --hard origin && git fetch origin && git checkout $BRANCH && git pull && git checkout $COMMIT)
"$PROJECT_DIR/scripts/utils/get_spread.sh"
"$PROJECT_DIR/scripts/utils/run_setup.sh" "$DEVICE_IP" "$DEVICE_PORT" "$SPREAD_SETUP" "$SPREAD_ENV" "$SPREAD_PARAMS"
"$PROJECT_DIR/scripts/utils/run_tests.sh" "$DEVICE_IP" "$DEVICE_PORT" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SPREAD_TESTS_SKIP" "$SPREAD_PARAMS"
