#!/bin/sh
set -x

# Remove snapd installed in the container to save some memory.
apt remove --purge -y snapd

# Install latest git, the workers then use git to fetch the repository instead of downloading a tarball.
add-apt-repository --yes ppa:git-core/ppa
apt-get install git -y

# Add the spread group and make spread setgid to that group
groupadd --system --gid 500 spread
cp spread /usr/local/bin/
chown root.spread /usr/local/bin/spread
chmod u=rwx,g=rxs,o=rx /usr/local/bin/spread

# Add gcloud configuration file that is readable only by the spread group
mkdir -p /home/ubuntu/.config/gcloud
cp sa.json /home/ubuntu/.config/gcloud/application_default_credentials.json
chown root.spread /home/ubuntu/.config/gcloud/application_default_credentials.json
chmod u=,g=r,o= /home/ubuntu/.config/gcloud/application_default_credentials.json

# Unpack the runner in the ~ of the ubuntu user
mkdir -p /home/ubuntu/actions-runner
tar -C /home/ubuntu/actions-runner -xf actions-runner-linux-x64-*.tar.gz
chown -R ubuntu.ubuntu /home/ubuntu/actions-runner