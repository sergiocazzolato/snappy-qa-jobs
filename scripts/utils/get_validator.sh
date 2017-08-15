#!/bin/bash
set -e

echo "Getting validator project and tpr command"

export TPR_DIR=$GOPATH/src/$TPR_URL
export PATH=$GOPATH/bin:$PATH

if [ -d $TPR_DIR ]; then
	echo "Validator already downloaded"
else
	mkdir -p $GOPATH
	go get $TPR_URL
fi
