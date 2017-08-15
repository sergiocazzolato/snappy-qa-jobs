#!/bin/bash
set -e
echo "Creating vm"

ARCHITECTURE=$1
CHANNEL=$2
PORT=$3
BRANCH=$4

export WORKSPACE=${WORKSPACE:-$(pwd)}

# Define variables
if [ $ARCHITECTURE == "amd64" ]; then
	ASSERTION=nested-amd64.model
    QEMU=qemu-system-x86_64
    PLATFORM=pc-amd64
    IMG="$pc.img"
elif [ $ARCHITECTURE == "i386" ]; then
	ASSERTION=nested-i386.model
    QEMU=qemu-system-i386
    PLATFORM=pc-i386
    IMG="pc.img"
else
	echo "Architecture $ARCHITECTURE not supported"
	exit 1
fi

# Install the dependencies
sudo apt install -y snapd qemu genisoimage sshpass unzip
sudo snap install ubuntu-image --edge --classic

# Prepare the image under test
WORKDIR=$WORKSPACE/work-dir
mkdir -p $WORKDIR

if [ ! -d snapd ]; then 
    git clone https://github.com/snapcore/snapd
fi
sudo /snap/bin/ubuntu-image --image-size 3G snapd/tests/lib/assertions/$ASSERTION --channel $CHANNEL -O $WORKDIR
genisoimage -volid cidata -joliet -rock -o assertions.disk snapd/tests/lib/assertions/auto-import.assert
mv assertions.disk $WORKDIR

# Run the vm
sudo systemd-run --unit sut-vm /usr/bin/$QEMU -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=$WORKDIR/$IMG,if=virtio,cache=none -drive file=$WORKSPACE/assertions.disk,if=virtio,cache=none -machine accel=kvm
sleep 180

# Create the test user on the vm
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'sudo adduser --extrausers --quiet --disabled-password --gecos "" test'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo test:ubuntu | sudo chpasswd'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo "test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/create-user-test'
