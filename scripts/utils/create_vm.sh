#!/bin/bash
set -x

echo "Creating vm"

ARCHITECTURE=$1
CHANNEL=$2
PORT=$3
BRANCH=$4

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

create_assertions_disk(){
    dd if=/dev/null of=assertions.disk bs=1M seek=1
    mkfs.ext4 -F assertions.disk
    mkdir /mnt/assertions
    mount -t ext4 -o loop assertions.disk /mnt/assertions
    cp "$TESTSLIB/assertions/auto-import.assert" /mnt/assertions
    umount /mnt/assertions && rm -rf /mnt/assertions
}

systemd_create_and_start_unit() {
    printf "[Unit]\nDescription=For testing purposes\n[Service]\nType=simple\nExecStart=%s\n" "$2" > "/run/systemd/system/$1.service"
    if [ -n "${3:-}" ]; then
        echo "Environment=$3" >> "/run/systemd/system/$1.service"
    fi
    systemctl daemon-reload
    systemctl start "$1"
}

echo "installing dependencies"
sudo apt update
sudo apt install -y snapd qemu genisoimage sshpass
sudo snap install --classic --beta ubuntu-image

echo "Download snapd and checkout branch"
if [ ! -d snapd ]; then
    git clone https://github.com/snapcore/snapd
fi
if [ ! -z $BRANCH ]; then
    (cd snapd && git checkout $BRANCH)
fi
export TESTSLIB="./snapd/tests/lib"

# determine arch related vars
case "$ARCHITECTURE" in
amd64)
    QEMU="$(which qemu-system-x86_64)"
    ;;
i386)
    QEMU="$(which qemu-system-i386)"
    ;;
*)
    echo "unsupported architecture"
    exit 1
    ;;
esac

# create ubuntu-core image
mkdir -p /tmp/work-dir

snap download core

/snap/bin/ubuntu-image --image-size 3G "$TESTSLIB/assertions/nested-${ARCHITECTURE}.model" --channel "$CHANNEL" --output ubuntu-core.img --extra-snaps core_*.snap
mv ubuntu-core.img /tmp/work-dir

create_assertions_disk

systemd_create_and_start_unit nested-vm "${QEMU} -m 1024 -nographic -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 -drive file=/tmp/work-dir/ubuntu-core.img,if=virtio,cache=none -drive file=${PWD}/assertions.disk,if=virtio,cache=none -machine accel=kvm"

wait_for_ssh
prepare_ssh

echo "Wait for first boot to be done"
while ! execute_remote "snap changes" | MATCH "Done.*Initialize system state"; do sleep 1; done

echo "VM Ready"