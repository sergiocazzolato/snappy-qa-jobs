#!/bin/sh
set -ex

INSTANCE_IP="${1:-localhost}"
INSTANCE_PORT="${2:-8022}"
USER="${3:-ubuntu}"
PASS="${4:-}"

CERT_NAME="spread_external"
PASSPHRASE="ubuntu"

execute_remote() {
    if [ -z "$PASS" ]; then
        ssh -p "$INSTANCE_PORT" -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$USER@$INSTANCE_IP" "$@"
    else
        sshpass -p "$PASS" ssh -p "$INSTANCE_PORT" -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$USER@$INSTANCE_IP" "$@"
    fi 
}

# Create certificates in case those are not stored
if [ ! -f "$CERT_NAME" ] || [ ! -f "$CERT_NAME" ]; then
	ssh-keygen -t rsa -N "$PASSPHRASE" -f "$CERT_NAME"
fi

execute_remote "sudo mkdir -p /root/.ssh"
execute_remote "sudo chmod 700 /root/.ssh"
cat "$CERT_NAME" | execute_remote "sudo tee -a /root/.ssh/authorized_keys > /dev/null"
