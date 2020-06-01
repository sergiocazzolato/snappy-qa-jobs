#!/bin/bash

SNAPD_NAME=snapd
SNAPD_ZIP=https://github.com/snapcore/snapd/archive/master.zip
CCONF_NAME=console-conf-tests
CCONF_ZIP=https://github.com/sergiocazzolato/console-conf-tests/archive/master.zip
JOBS_NAME=snappy-qa-jobs
JOBS_ZIP=https://github.com/sergiocazzolato/snappy-qa-jobs/archive/master.zip

PROJECT_URL=$1
PROJECT_NAME=$2
BRANCH=${3:-}
COMMIT=${4:-}

if [ -z "$PROJECT_NAME" ]; then
	echo "Project name cannot be empty, exiting..."
	exit 1
fi

rm -rf "$PROJECT_NAME"-master "$PROJECT_NAME"

if [ -n "$PROJECT_URL" ]; then
	git clone "$PROJECT_URL" "$PROJECT_NAME"	
else
	if [ "$PROJECT_NAME" == '$SNAPD_NAME' ]; then
		wget "$SNAPD_ZIP"
	elif [ "$PROJECT_NAME" == '$CCONF_NAME' ]; then
		wget "$CCONF_ZIP"
	elif [ "$PROJECT_NAME" == '$JOBS_NAME' ]; then
		wget "$JOBS_ZIP"
	else
		echo "Project configuration not supported, exiting..."
		exit 1
	fi
	unzip -q master.zip
	mv "$PROJECT_NAME"-master "$PROJECT_NAME"
fi

if [ -n "$BRANCH" ]; then
	( cd "$PROJECT_NAME" && git checkout "$BRANCH" )
fi
if [ -n "$COMMIT" ]; then
	( cd "$PROJECT_NAME" && git checkout "$COMMIT" )
fi

echo "Project downloaded and configured."
