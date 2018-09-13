#!/bin/bash

git clone $SNAPD_URL $PROJECT
(cd $PROJECT && git fetch origin && git checkout $BRANCH && git pull)
. "$SCRIPTS_DIR/utils/get_spread.sh"
. "$SCRIPTS_DIR/utils/run_spread.sh" "127.0.0.1" "22" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" "$SPREAD_PARAMS" | tee run_spread.log
