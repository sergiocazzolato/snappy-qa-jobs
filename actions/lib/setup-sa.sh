#!/bin/sh
set -x

# Add gcloud configuration file that is readable only by the spread group
mkdir -p /home/ubuntu/.config/gcloud
cp sa.json /home/ubuntu/.config/gcloud/application_default_credentials.json
chown root.spread /home/ubuntu/.config/gcloud/application_default_credentials.json
chmod u=,g=r,o= /home/ubuntu/.config/gcloud/application_default_credentials.json
