#!/bin/bash
set -e
echo "Creating vm"

ARCHITECTURE=$1
CHANNEL=$2
PORT=$4

# Define variables
if [ $ARCHITECTURE == "amd64" ]; then
	ASSERTION=nested-amd64.model
    QEMU=qemu-system-x86_64
    PLATFORM=pc-amd64
    IMG="validator/images/$PLATFORM-$CHANNEL/pc-amd64.img"
elif [ $ARCHITECTURE == "i386" ]; then
	ASSERTION=nested-i386.model
    QEMU=qemu-system-i386
    PLATFORM=pc-i386
    IMG="validator/images/$PLATFORM-$CHANNEL/pc-i386.img"
else
	echo "Architecture $ARCHITECTURE not supported"
	exit 1
fi

# Install the dependencies
sudo apt install -y snapd qemu genisoimage sshpass unzip
sudo snap install ubuntu-image

if [ -f validator/create.sh ]; then
    sudo validator/create.sh $CHANNEL $PLATFORM
else
    echo "Validator project not available"
    exit 1
fi

# Run the vm
sudo systemd-run --unit sut-vm /usr/bin/$QEMU -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=$IMG,if=virtio,cache=none -drive file=$WORKDIR/assertions.disk,if=virtio,cache=none -machine accel=kvm
sleep 180

# Create the test user on the vm
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'sudo adduser --extrausers --quiet --disabled-password --gecos "" test'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo test:ubuntu | sudo chpasswd'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo "test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/create-user-test'
