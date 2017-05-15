#!/bin/bash
set -ex

ARCHITECTURE=$1
CHANNEL=$2
SPREAD_SUITE=$3
USE_PROXY=$4
SNAPD_URL=https://github.com/snapcore/snapd
SPREAD_URL=http://people.canonical.com/~sjcazzol/snappy/spread-amd64.tar.gz

PORT=8022
WORKSPACE=$(pwd)

# Prepare job

if [ $ARCHITECTURE == "amd64" ]; then
	ASSERTION=nested-amd64.model
    QEMU=qemu-system-x86_64
    SPREAD_SYS=ubuntu-core-16-64
elif [ $ARCHITECTURE == "i386" ]; then
	ASSERTION=nested-i386.model
    QEMU=qemu-system-i386
    SPREAD_SYS=ubuntu-core-16-32
else
	echo "Architecture $ARCHITECTURE not supported"
	exit 1
fi

# Get spread

wget $SPREAD_URL

# Configura the proxy

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
git clone $SNAPD_URL
mkdir -p work-dir

sudo ubuntu-image --image-size 3G snapd/tests/lib/assertions/$ASSERTION --channel $CHANNEL --output ubuntu-core.img
mv ubuntu-core.img work-dir

genisoimage -volid cidata -joliet -rock -o assertions.disk snapd/tests/lib/assertions/auto-import.assert

sudo systemd-run --unit sut-vm-$ARCHITECTURE /usr/bin/$QEMU -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=$WORKSPACE/work-dir/ubuntu-core.img,if=virtio,cache=none -drive file=$WORKSPACE/assertions.disk,if=virtio,cache=none -machine accel=kvm
sleep 180

# Create the test user
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'sudo adduser --extrausers --quiet --disabled-password --gecos "" test'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo test:ubuntu | sudo chpasswd'
sshpass -p ubuntu ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $PORT user1@localhost 'echo "test ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/create-user-test'


# Create file with proxy variables
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

# Run Spread tests
tar xzvf spread-amd64.tar.gz
rm -f spread-amd64.tar.gz
mv spread work-dir
cd snapd
SPREAD_EXTERNAL_ADDRESS=localhost:$PORT $WORKSPACE/work-dir/spread -v -xunit external:$SPREAD_SYS:$SPREAD_SUITE
