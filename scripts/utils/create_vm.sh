#!/bin/bash
set -x

echo "Creating vm"

ARCHITECTURE=$1
CHANNEL=$2
PORT=$3
BRANCH=$4

export WORKSPACE=${WORKSPACE:-$(pwd)}

execute_remote(){
    sshpass -p ubuntu ssh -p $PORT -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user1@localhost "$*"
}

wait_for_ssh(){
    retry=300
    while ! execute_remote true; do
        retry=$(( retry - 1 ))
        if [ $retry -le 0 ]; then
            echo "Timed out waiting for ssh. Aborting!"
            exit 1
        fi
        sleep 1
    done
}

prepare_ssh(){
    execute_remote "sudo adduser --extrausers --quiet --disabled-password --gecos '' test"
    execute_remote "echo test:ubuntu | sudo chpasswd"
    execute_remote "echo 'test ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/test-user"
}

# Define variables
if [ $ARCHITECTURE == "amd64" ]; then
	ASSERTION=nested-amd64.model
    QEMU=qemu-system-x86_64
    PLATFORM=pc-amd64
    IMG="pc.img"
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

if [ ! -f $WORKDIR/$IMG ] || [ ! -f $WORKDIR/assertions.disk ]; then
    echo "Some needed files does not exist, could be either $WORKDIR/$IMG or $WORKDIR/assertions.disk"
    exit 1
fi

# Run the vm
sudo systemd-run --unit sut-vm /usr/bin/$QEMU -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=$WORKDIR/$IMG,if=virtio,cache=none -drive file=$WORKDIR/assertions.disk,if=virtio,cache=none -machine accel=kvm

echo "Wait for ssh ready and addind test user to the vm"
wait_for_ssh
prepare_ssh

echo "VM Ready"
