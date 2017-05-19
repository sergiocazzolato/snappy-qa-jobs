#!/bin/bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
fi

ARCHITECTURE=$1
CHANNEL=$2
USE_PROXY=$3
PORT=$4

# Define variables
WORKSPACE=$(pwd)
if [ $ARCHITECTURE == "amd64" ]; then
	ASSERTION=nested-amd64.model
    QEMU=qemu-system-x86_64
elif [ $ARCHITECTURE == "i386" ]; then
	ASSERTION=nested-i386.model
    QEMU=qemu-system-i386
else
	echo "Architecture $ARCHITECTURE not supported"
	exit 1
fi

# Configure the proxy if needed
if [ $USE_PROXY == "USE_PROXY" ]; then
    export http_proxy=http://squid.internal:3128
    export HTTP_PROXY=http://squid.internal:3128
    export https_proxy=https://squid.internal:3128
    export HTTPS_PROXY=https://squid.internal:3128
fi

# Install the dependencies
sudo apt install -y snapd qemu genisoimage sshpass
sudo apt install -y ubuntu-image
sudo apt install -y unzip
sudo apt install -y sshpass

# Prepare the image under test
WORKDIR=$WORKSPACE/work-dir
mkdir -p $WORKDIR

git clone https://github.com/snapcore/snapd
sudo ubuntu-image --image-size 3G snapd/tests/lib/assertions/$ASSERTION --channel $CHANNEL --output ubuntu-core.img
mv ubuntu-core.img $WORKDIR

genisoimage -volid cidata -joliet -rock -o assertions.disk snapd/tests/lib/assertions/auto-import.assert
mv assertions.disk $WORKDIR

# Run the vm
sudo systemd-run --unit sut-vm /usr/bin/$QEMU -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=$WORKDIR/ubuntu-core.img,if=virtio,cache=none -drive file=$WORKDIR/assertions.disk,if=virtio,cache=none -machine accel=kvm
sleep 180

# Create file with proxy variables on the vm if needed
if [ $USE_PROXY == "USE_PROXY" ]; then
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo cp /etc/environment /root/testenv"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo  sed -i '$ a\http_proxy=http://squid.internal:3128' /root/testenv"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo  sed -i '$ a\https_proxy=https://squid.internal:3128' /root/testenv"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo  sed -i '$ a\HTTP_PROXY=http://squid.internal:3128' /root/testenv"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo  sed -i '$ a\HTTPS_PROXY=https://squid.internal:3128' /root/testenv"


    # Prepare to mount the proxy variables permanently
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "cat <<EOF > etc-environment.mount
[Unit]
Description=Mount unit for snapd proxy

[Mount]
What=/root/testenv
Where=/etc/environment
Type=none
Options=nodev,ro,bind

[Install]
WantedBy=multi-user.target
EOF"

    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo mv ~/etc-environment.mount /etc/systemd/system/etc-environment.mount"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo systemctl enable etc-environment.mount"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo systemctl start etc-environment.mount"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo systemctl stop snapd.service snapd.socket"
    sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost "sudo systemctl start snapd.service snapd.socket"
fi 

# Remove snapd code
rm -rf snapd
