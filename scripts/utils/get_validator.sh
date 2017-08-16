#!/bin/bash

echo "Getting validator project and tpr command"
export GOPATH=${GOPATH:-$(pwd)/gopath}
export TPR_DIR=$GOPATH/src/$TPR_URL
export VALIDATOR_DIR=$GOPATH/src/$TPR_URL
export PATH=$GOPATH/bin:$PATH

if [ -d $TPR_DIR ]; then
	echo "Validator already downloaded"
else
	mkdir -p $GOPATH
	go get $TPR_URL
fi
