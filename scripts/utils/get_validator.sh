#!/bin/bash
set -e

echo "Getting validator project and tpr command"

export VALIDATOR_DIR=$WORKSPACE/validator
export PATH=$GOPATH/bin:$PATH

if [ -d $VALIDATOR_DIR ]; then
	echo "Validator already downloaded"
else
	mkdir -p $GOPATH
	go get $TPR_URL
fi
