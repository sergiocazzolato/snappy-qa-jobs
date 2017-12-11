#!/bin/bash

git clone $SNAPD_URL $PROJECT
(cd $PROJECT && git fetch origin && git checkout $BRANCH && git pull)
. "$SCRIPTS_DIR/utils/get_spread.sh"
cp $PROJECT/spread.yaml $PROJECT/spread.yaml.bak
sed 's/ubuntu-16.04-32/ubuntu-17.04-64/g' -i $PROJECT/spread.yaml
sed 's/debian-9-64/ubuntu-17.10-64/g' -i $PROJECT/spread.yaml
. "$SCRIPTS_DIR/utils/run_spread.sh" "127.0.0.1" "22" "$PROJECT" "$SPREAD_TESTS" "$SPREAD_ENV" "$SKIP_TESTS" | tee run_spread.log
cp $PROJECT/spread.yaml.bak $PROJECT/spread.yaml