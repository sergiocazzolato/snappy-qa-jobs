#!/bin/bash

git clone $SNAPD_URL
(cd $PROJECT && git checkout $BRANCH)
. "$SCRIPTS_DIR/utils/get_spread.sh"
. "$SCRIPTS_DIR/utils/run_spread.sh" "127.0.0.1" "22" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" | tee run_spread.log
