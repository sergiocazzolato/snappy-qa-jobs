#!/bin/bash

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters: $#"
    i=1
    for param in $*; do
        echo "param $i: $param"
        i=$(( i + 1 ))
    done
    exit 1
fi

DEVICE=$1
CHANNEL=$2
VERSION=$3
LP_ID=${4:-sergio-j-cazzolato}
TF_JOB=job.yaml
TF_CLIENT=/snap/bin/testflinger-cli

# Define the queue to use
DEVICE_QUEUE=
if [ "$DEVICE" = pi2 ]; then
	DEVICE_QUEUE=
elif [ "$DEVICE" = pi3 ]; then
	DEVICE_QUEUE=rpi3b
elif [ "$DEVICE" = pi4 ]; then
	DEVICE_QUEUE=rpi4b8g
elif [ "$DEVICE" = dragonboard ]; then
	DEVICE_QUEUE=dragonboard
else
	echo "Device not supported"
	exit 1
fi

# Define the url to get
if [ "$VERSION" != 16 ] && [[ "$DEVICE" =~ pi* ]]; then
	IMAGE="pi.img.xz"
else	
	IMAGE="${DEVICE}.img.xz"
fi
URL=https://storage.googleapis.com/spread-snapd-tests/images/$DEVICE-$VERSION-$CHANNEL/$IMAGE

# Install testflinger client in case it is not installed
if ! snap list testflinger-cli; then
    sudo snap install testflinger-cli    
fi

cat > "$TF_JOB" <<EOF
job_queue: $DEVICE_QUEUE
global_timeout: 36000
provision_data:
  url: $URL
reserve_data:
  ssh_keys:
    - lp:$LP_ID
EOF

echo "Submitting job to testflinger"
JOB_ID=$("$TF_CLIENT" submit -q "$TF_JOB")
echo "JOB_ID: ${JOB_ID}"

echo "Print job: $TF_JOB "
cat "$TF_JOB" | tee "${JOB_ID}.job"

echo "Showing job data"
"$TF_CLIENT" poll "${JOB_ID}" | tee "${JOB_ID}.log"