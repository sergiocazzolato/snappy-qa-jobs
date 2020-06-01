#!/bin/bash

SNAPD_NAME=snapd
SNAPD_ZIP=https://github.com/snapcore/snapd/archive/master.zip
CCONF_NAME=console-conf-tests
CCONF_ZIP=https://github.com/sergiocazzolato/console-conf-tests/archive/master.zip
JOBS_NAME=snappy-qa-jobs
JOBS_ZIP=https://github.com/sergiocazzolato/snappy-qa-jobs/archive/master.zip

PROJECT_URL=$1
PROJECT_NAME=$2
BRANCH=${3:-master}
COMMIT=${4:-}

if [ -z "$PROJECT_NAME" ]; then
	echo "Project name cannot be empty, exiting..."
	exit 1
fi

if [ -n "$PROJECT_URL" ]; then
	rm -rf "$PROJECT_NAME"
	git clone "$PROJECT_URL" "$PROJECT_NAME"
	( cd "$PROJECT_NAME" && git checkout "$BRANCH" )
	if [ -n "$COMMIT" ]; then
		( cd "$PROJECT_NAME" && git checkout "$COMMIT" )
	fi
	echo "Project downloaded and configured."
	exit 0
fi

echo "Project url not provided, using the defaults"

if [ "$PROJECT_NAME" == '$SNAPD_NAME' ]; then
	wget "$SNAPD_ZIP"
	unzip -q master.zip
	( cd "$PROJECT_NAME"-master && git checkout "$BRANCH" )
elif [ "$PROJECT_NAME" == '$CCONF_NAME' ]; then
	wget "$CCONF_ZIP"
	unzip -q master.zip
	( cd "$PROJECT_NAME"-master && git checkout "$BRANCH" )
elif [ "$PROJECT_NAME" == '$JOBS_NAME' ]; then
	wget "$JOBS_ZIP"
	unzip -q master.zip
	( cd "$PROJECT_NAME"-master && git checkout "$BRANCH" )
else
	echo "Project configuration not supported, exiting..."
	exit 1
fi

echo "Project downloaded and configured."
