## Running tests
Comming soon

## Examples

##### Beta branch on amd64 vm
DEVICE_USER=sergio-j-cazzolato DEVICE_PORT=8022 BRANCH=2.27.2 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_amd64

##### Beta branch on pi2/3

DEVICE_IP=192.168.1.6 DEVICE_USER=sergio-j-cazzolato BRANCH=2.27.2 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi

##### Upgrade from stable on dragonboard
BRANCH=2.27.2 ~/workspace/snappy-qa-jobs/scripts/run_tf_db_split.sh tf_snapd_db_split_refresh

##### Upgrade from stable on pi2/3
DEVICE_IP=10.42.0.67 DEVICE_USER=sergio-j-cazzolato BRANCH=2.27.2 ~/workspace/snappy-qa-jobs/scripts/run_external_device.sh dev_snapd_pi_refresh

##### Core revert test on linode
BRANCH=2.27.2 ~/workspace/snappy-qa-jobs/scripts/run_linode.sh lin_snapd_amd64_core_revert