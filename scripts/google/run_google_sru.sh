#!/bin/bash

git clone "$PROJECT_URL" "$PROJECT"

. "$SCRIPTS_DIR/utils/snap_info.sh"
sudo apt install -y jq
if [ "$BRANCH" = beta ]; then
	BRANCH=$(get_beta_branch "$ARCH")
elif [ "$BRANCH" = edge ]; then
	BRANCH=$(get_edge_commit "$ARCH")
fi

(cd $PROJECT && git reset --hard origin && git fetch origin && git checkout $BRANCH && git pull && git checkout $COMMIT)
"$SCRIPTS_DIR"/utils/get_spread.sh
"$SCRIPTS_DIR"/utils/run_tests.sh "127.0.0.1" "22" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SPREAD_TESTS_SKIP" "$SPREAD_PARAMS"
