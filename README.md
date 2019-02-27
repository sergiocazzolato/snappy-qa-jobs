## About this project

This project provides a set of scripts intended to accelerate the snappy validation process over the diferent platforms and devices supported. 

The scripts are ready to run spread tests for the different scenarios on actual devices, test flinger devices, local vms and to create vms with 
ubuntu core inside test flinger machines.

The default configuration of the project is ready to run beta validation process.

## Smoke test execution

Smoke test suite is used to validate a core snap is working on an specific channel.

The initial use case for this test suite is to validate the core snap when it is promoted to stable release, but it can be
used for validating other channels too.

To run this test suite it is needed to specify the core version and channel. The following line shows how to run it:

    SPREAD_CORE_VERSION=2.37.4 SPREAD_CORE_CHANNEL=stable spread google:tasks/smoke/

The current systems are using base images with no dependencies installed on google compute engine.

Next step is to extend the suite to run the same tests but on devices.

## Beta validation

In this section it is explained how to run beta validation by using this project. To complete beta validation all the following tests have to be executed on dragonboard, rpi2, rpi3, core64 and core32.

### Create beta images

By running the following lines, the script will create the images for beta validation for all the supported devices.

    git clone https://github.com/sergiocazzolato/validator.git
    cd validator
    sudo ./create.sh beta <core-number>

with core-number = <16|18>

### Get stable images used to run the refresh core scenario

Download the core 16 images from: http://cdimage.ubuntu.com/ubuntu-core/16/stable/current/
Download the core 18 images from: http://cdimage.ubuntu.com/ubuntu-core/18/stable/current/

It is possible to use older images too to validate the refresh scenario. 

### Setup a device:

    sudo dd if=<PAT_TO_IMG> of=/dev/mmcblk0 bs=4M oflag=sync status=noxfer

### Create a vm:

#### Core 16

    old kvm:

    amd64: kvm -snapshot -smp 2 -m 1500 -redir tcp:8022::22 -nographic -serial mon:stdio <PATH_TO_VM_IMAGE>
    i386: kvm -snapshot -smp 2 -m 1500 -redir tcp:8023::22 -nographic -serial mon:stdio <PATH_TO_VM_IMAGE>

    new kvm:

    amd64: sudo kvm -snapshot -smp 2 -m 1500 -net nic,model=virtio -net user,hostfwd=tcp::8022-:22 -nographic -serial mon:stdio <PATH_TO_VM_IMAGE>
    i386: sudo kvm -snapshot -smp 2 -m 1500 -net nic,model=virtio -net user,hostfwd=tcp::8023-:22 -nographic -serial mon:stdio <PATH_TO_VM_IMAGE>

#### Core 18

    amd64: sudo kvm -snapshot -smp 2 -m 2000 -net nic,model=virtio -net user,hostfwd=tcp::8022-:22 -serial mon:stdio <PATH_TO_VM_IMAGE>    
    i386: sudo kvm -snapshot -smp 2 -m 2000 -net nic,model=virtio -net user,hostfwd=tcp::8023-:22 -serial mon:stdio <PATH_TO_VM_IMAGE>

    Note: it could be needed to provide initial entropy by moving the mouse and using the keyboard in the kvm window.

### Access to console through screen:

    sudo screen /dev/ttyUSB0 115200

### Run beta validation

To complete beta validation is requested to run all the following scenario. For all of them, it is needed to save the results, analize and track test failures:

##### Execution with an image built from the beta channel with kernel from stable:
    Db: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_db
    Amd64: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_amd64
    I386: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_i386
    Pi2: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_pi
    Pi3: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_pi

##### Refresh core from stable image to beta channel before the execution:
    Db: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_db_refresh
    Amd64: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_amd64_refresh
    I386: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_i386_refresh
    Pi2: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_pi_refresh
    Pi3: DEVICE_IP=<DEVICE_IP> DEVICE_USER=<DEVICE_USER> BRANCH=<BRANCH> scripts/run_external_device.sh dev_snapd_pi_refresh

##### console-conf automated tests:
    Db: DEVICE_USER=<DEVICE_USER> WIFI_SSID=<WIFI_SSID> WIFI_PASSWORD=<WIFI_PASSWORD> DEVICE_IP=<DEVICE_IP> scripts/run_external_device.sh dev_cconf_db
    Amd64: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh tf_cconf_amd64
    I386: DEVICE_PORT=<DEVICE_PORT> DEVICE_USER=<DEVICE_USER> ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh tf_cconf_i386
    Pi2: DEVICE_USER=<DEVICE_USER> DEVICE_IP=<DEVICE_IP> scripts/run_external_device.sh dev_cconf_pi2
    Pi3: DEVICE_USER=<DEVICE_USER> WIFI_SSID=<WIFI_SSID> WIFI_PASSWORD=<WIFI_PASSWORD> DEVICE_IP=<DEVICE_IP> scripts/run_external_device.sh dev_cconf_pi3

In order to run console-conf tests, it is needed to run console-conf manually once in order to get the device ip to use it on the tests. Make sure the network conections are setup for different devices, i.e. on pi3 the ethernet and wifi need to be setup initially. 

##### core revert test:
    16.04-64: BRANCH=<BRANCH> scripts/run_google.sh goo_snapd_amd64_core_revert


##### Running individual tests

It is occasionally useful to re-run a specific test (or set of tests), or skip a test. This is supported by SPREAD_TESTS and SKIP_TESTS variables passed to the scripts along with the standard variables, e.g.
    SPREAD_TESTS=external:ubuntu-core-16-arm-64:tests/main/interfaces-hostname-control,external:ubuntu-core-16-arm-64:tests/main/snap-logs
    SKIP_TESTS=tests/main/revert-devmode

##### Notes

<DEVICE_IP> = The ip of the device that's gonna be tested, in case there are two ips (wifi and lan), it is more reliable to use the lan.
<DEVICE_USER> = The user for whom the device to test is registered.
<DEVICE_PORT> = The port used to ssh to the device, it is mostly used when the device is a local vm.
<BRANCH> = The branch corresponding to the release to validate.
<WIFI_SSID> = The ssid for the wifi that is gonna used to validate
<WIFI_PASSWORD> = The password to connect the device to the wifi

In case of dragonboard it can be tested on testflinger. For that it is needed to install the testflinger-cli snap and run the tests connected to the vpn. See the examples section to see how to run it. 

## Examples

The following section shows the examples that are used to execution beta validation for core 16 and core 18

### Beta Execution

##### Beta branch on amd64 using local vm
    DEVICE_USER=sergio-j-cazzolato DEVICE_PORT=8022 BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_amd64
    DEVICE_USER=sergio-j-cazzolato DEVICE_PORT=8022 BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_amd64_18

##### Beta branch on i386 using local vm
    DEVICE_USER=sergio-j-cazzolato DEVICE_PORT=8023 BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_i386
    DEVICE_USER=sergio-j-cazzolato DEVICE_PORT=8023 BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_i386_18

##### Beta branch on pi2/pi3
    DEVICE_IP=10.42.0.67 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi
    DEVICE_IP=10.42.0.67 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi_18

##### Beta branch on dragonboard
    DEVICE_IP=192.168.1.8 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_db
    DEVICE_IP=192.168.1.8 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_db_18


##### Beta branch on dragonboard using testflinger
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_device.sh tf_snapd_db    

##### Beta branch on cm3 using testflinger
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_device.sh tf_snapd_cm3

##### Beta branch on amd64 using testflinger vm
    IMAGE_URL=http://<GCE-IP>/validator/images/pc-amd64-16-beta/pc.img BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_amd64
    IMAGE_URL=http://<GCE-IP>/validator/images/pc-amd64-18-beta/pc.img BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_amd64_18

##### Beta branch on i386 using testflinger vm
    IMAGE_URL=http://<GCE-IP>/validator/images/pc-i386-16-beta/pc.img BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_i386
    IMAGE_URL=http://<GCE-IP>/validator/images/pc-i386-18-beta/pc.img BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_i386_18


### Beta refresh from stable

##### Upgrade from stable on amd64 using local vm
    DEVICE_PORT=8022 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_amd64_refresh
    DEVICE_PORT=8022 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_amd64_refresh_18

##### Upgrade from stable on i386 using local vm
    DEVICE_PORT=8023 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_i386_refresh
    DEVICE_PORT=8023 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_i386_refresh_18

##### Upgrade from stable on pi2/3
    DEVICE_IP=10.42.0.67 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi_refresh
    DEVICE_IP=10.42.0.67 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi_refresh_18

##### Upgrade from stable on db
    DEVICE_IP=192.168.1.8 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_db_refresh
    DEVICE_IP=192.168.1.8 DEVICE_USER=sergio-j-cazzolato BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_db_refresh_18

##### Upgrade from stable on dragonboard using testflinger
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_device.sh tf_snapd_db_refresh

##### Upgrade from stable on cm3 using testflinger
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_device.sh tf_snapd_cm3_refresh

##### Upgrade from stable on amd64 using testflinger vm
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_amd64_refresh

##### Upgrade from stable on i386 using testflinger vm
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_tf_vm.sh tf_snapd_i386_refresh


### Core revert

##### Core revert test on google
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_google.sh goo_snapd_amd64_core_revert


### Console conf

##### Console conf on local amd64 using local vm
    DEVICE_USER=sergio-j-cazzolato DEVICE_IP=localhost DEVICE_PORT=8022 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh tf_cconf_amd64

##### Console conf on local i386 using local vm
    DEVICE_USER=sergio-j-cazzolato DEVICE_IP=localhost DEVICE_PORT=8023 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh tf_cconf_i386

##### Console conf on pi2
    DEVICE_USER=sergio-j-cazzolato DEVICE_IP=10.42.0.24 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_cconf_pi2

##### Console conf on pi3
    DEVICE_USER=sergio-j-cazzolato WIFI_SSID=put-your-ssid WIFI_PASSWORD=put-the-pwd DEVICE_IP=192.168.1.6 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_cconf_pi3

##### Console conf on dragonboard
    DEVICE_USER=sergio-j-cazzolato WIFI_SSID=put-your-ssid WIFI_PASSWORD=put-the-pwd DEVICE_IP=192.168.1.8 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_cconf_db



### SRU validation

##### SRU validation execution on google machines
    BRANCH=2.37.4 ~/workspace/snappy-qa-jobs/scripts/run_google_sru.sh goo_snapd_sru_validation

##### SRU validation setup on external desktop machine
    DEVICE_USER=ubuntu DEVICE_PASS=pass DEVICE_IP=192.168.1.8 ~/workspace/snappy-qa-jobs/scripts/run_external_device_sru.sh dev_snapd_sru_validation


