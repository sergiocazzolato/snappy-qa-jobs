#!/bin/bash
set -x

echo "Creating vm"

echo "installing nested dependencies"
sudo apt install -y qemu qemu-utils genisoimage sshpass qemu-kvm cloud-image-utils ovmf kpartx git unzip

echo "installing snapd from ppa with version 2.45"
sudo apt-add-repository -y http://ppa.launchpad.net/snappy-dev/image/ubuntu
sudo apt update
sudo apt install -y snapd

echo "Installing snaps needed"
sudo snap install core --beta
sudo snap install ubuntu-image --classic

ARCHITECTURE=$1
IMAGE_URL=$2
USER_ASSERTION_URL=$3
BUILD_SNAPD=$4

if test "$(lsb_release -cs)" = focal; then
    # Install snapd and add variables
    mkdir -p /home/gopath
    wget https://github.com/snapcore/snapd/archive/master.zip
    unzip -q master.zip

    export PROJECT_PATH="./snapd-master"
    export TESTSLIB=./snapd-master/tests/lib
    export GOHOME=/home/gopath
    export GOPATH="$GOHOME"
    export SPREAD_PATH="$GOHOME"
    export SPREAD_SYSTEM=ubuntu-20.04-64
    export PATH="$GOHOME/bin:/snap/bin:$PATH:/usr/lib/go-1.6/bin:/var/lib/snapd/snap/bin:$TESTSLIB/bin"

    # Define variables used to the nested vm
    export NESTED_TYPE=core
    export SPREAD_BACKEND=external
    export NESTED_ARCHITECTURE="$ARCHITECTURE"
    export CORE_CHANNEL=edge
    export BUILD_FROM_CURRENT="$BUILD_SNAPD"
    export USE_CLOUD_INIT=true
    export ENABLE_SECURE_BOOT=true
    export ENABLE_TPM=true
    export CUSTOM_IMAGE_URL="$IMAGE_URL"
  
    if [ "$BUILD_FROM_CURRENT" == "true" ]; then
         # Create test user
        sudo groupadd --gid 12345 test
        adduser --uid 12345 --gid 12345 --disabled-password --gecos '' test

        # Build snapd
        echo "installing snapd build dependencies"
        sudo apt install -y golang
        go get -u github.com/kardianos/govendor

        "$TESTSLIB"/prepare-restore.sh --prepare-project
    fi

    # Update the memory used by the vm until is it possible to configure it
    sed -i -e 's/-m 4096/-m 2048/g' "$TESTSLIB"/nested.sh

    # Create and run nested vm
    . "$TESTSLIB"/nested.sh
    create_nested_core_vm
    start_nested_core_vm
    echo "VM Ready"
else
    execute_remote(){
        sshpass -p ubuntu ssh -p $PORT -q -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user1@localhost "$*"
    }

    wait_for_ssh(){
        retry=150
        while ! execute_remote true; do
            retry=$(( retry - 1 ))
            if [ $retry -le 0 ]; then
                echo "Timed out waiting for ssh. Aborting!"
                return 1
            fi
            sleep 1
        done
        return 0
    }

    wait_for_no_ssh(){
        retry=150
        while execute_remote true; do
            retry=$(( retry - 1 ))
            if [ $retry -le 0 ]; then
                echo "Timed out waiting for no ssh. Aborting!"
                return 1
            fi
            sleep 1
        done
        return 0
    }

    prepare_ssh(){
        execute_remote "sudo adduser --extrausers --quiet --disabled-password --gecos '' test"
        execute_remote "echo test:ubuntu | sudo chpasswd"
        execute_remote "echo 'test ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/test-user"
    }

    create_cloud_init_config(){
        cat <<EOF > "$WORK_DIR/user-data"
#cloud-config
  ssh_pwauth: True
  users:
   - name: user1
     sudo: ALL=(ALL) NOPASSWD:ALL
     shell: /bin/bash
  chpasswd:
   list: |
    user1:ubuntu
   expire: False
EOF

        cat <<EOF > "$WORK_DIR/meta-data"
instance_id: cloud-images
EOF

        loops=$(kpartx -avs "$WORK_DIR/ubuntu-core.img"  | cut -d' ' -f 3)
        part=$(echo "$loops" | tail -1)
        tmp=$(mktemp -d)
        mount "/dev/mapper/$part" "$tmp"

        mkdir -p "$tmp/system-data/var/lib/cloud/seed/nocloud-net/"
        cp "$WORK_DIR/user-data" "$tmp/system-data/var/lib/cloud/seed/nocloud-net/"
        cp "$WORK_DIR/meta-data" "$tmp/system-data/var/lib/cloud/seed/nocloud-net/"

        umount "$tmp"
        kpartx -d "$WORK_DIR/ubuntu-core.img"
    }

    systemd_create_and_start_unit() {
        printf "[Unit]\nDescription=For testing purposes\n[Service]\nType=simple\nExecStart=%s\n" "$2" > "/run/systemd/system/$1.service"
        if [ -n "${3:-}" ]; then
            echo "Environment=$3" >> "/run/systemd/system/$1.service"
        fi
        systemctl daemon-reload
        systemctl start "$1"
    }

    get_qemu_for_nested_vm(){
        case "$ARCHITECTURE" in
        amd64)
            command -v qemu-system-x86_64
            ;;
        i386)
            command -v qemu-system-i386
            ;;
        *)
            echo "unsupported architecture"
            exit 1
            ;;
        esac
    }

    export PORT=8022
    export WORK_DIR=/tmp/work-dir
    export QEMU=$(get_qemu_for_nested_vm)

    # create ubuntu-core image
    mkdir -p "$WORK_DIR"

    if [[ "$IMAGE_URL" == *.img.xz ]]; then
        curl -L -o "$WORK_DIR/ubuntu-core.img.xz" "$IMAGE_URL"
        unxz "$WORK_DIR/ubuntu-core.img.xz"
    elif [[ "$IMAGE_URL" == *.img ]]; then
        curl -L -o "$WORK_DIR/ubuntu-core.img" "$IMAGE_URL"
    else
        echo "Image extension not supported, exiting..."
        exit 1
    fi

    create_cloud_init_config

    systemd_create_and_start_unit nested-vm "${QEMU} -m 2048 -nographic -snapshot \
        -net nic,model=virtio -net user,hostfwd=tcp::$PORT-:22 \
        -serial mon:stdio -machine accel=kvm \
        $WORK_DIR/ubuntu-core.img"

    if wait_for_ssh; then
        prepare_ssh
    else
        echo "ssh not established, exiting..."
        journalctl -u nested-vm -n 150
        exit 1
    fi

    echo "Wait for first boot to be done"
    while ! execute_remote "snap changes" | grep -q -E "Done.*Initialize system state"; do
        sleep 1
    done

    echo "VM Ready"
fi




