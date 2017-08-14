#!/bin/bash
set -e

export VALIDATOR_DIR=$WORSKPACE/validator
export PATH=$VALIDATOR_DIR/cmd/tpr/:$PATH

if [ -d $VALIDATOR_DIR ]; then
	exit
fi

git clone https://github.com/fgimenez/validator.git $VALIDATOR_DIR
go build -o $VALIDATOR_DIR/cmd/tpr/tpr $VALIDATOR_DIR/cmd/tpr/main.go
