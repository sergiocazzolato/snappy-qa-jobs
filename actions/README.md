# Setting up GitHub worker (Improved)
# Setting up GitHub worker
## Preparation
You will need a machine running Ubuntu 20.04 os newer. Spare laptop or desktop / server preferred. Usage on main machine may be annoying because of extra load, suspend-resume or development induced impact on the workers.

Install the basic ubuntu server. Install lxd and fetch ubuntu:20.04 image by spawning a toy container. Container image download was extremely slow, at least from my location. This is a known issue as there’s no mirror or CDN for those.

```
sudo snap install lxd
lxd init —auto
```

Install and **configure** canonical-livepatch, for extra security.
```
sudo snap install canonical-livepatch
```
NOTE: You must create a token for canonical-livepatch. Otherwise it is not doing anything useful.

## Preparing helper content

### Build spread
Install go (snap works great) and build spread from master  
```
sudo snap install --classic go
go get -u github.com/snapcore/spread/cmd/spread
```

The binary will be in `~/go/bin/spread`.

### Download worker binaries
Download actions-runner-linux from GitHub: https://github.com/actions/runner/releases (expand assets on the last release to see). There are binaries for Linux, MacOS and Windows.

The latest version as of this time is
curl -O -L https://github.com/actions/runner/releases/download/v2.273.5/actions-runner-linux-x64-2.273.5.tar.gz

I’ve used an older version (165) as that was recommended by GitHub at the time.

### Prepare setup.sh script
Create a script `setup.sh`, check the contents so that it contains your gcloud credentials from `~/.config/gcloud/application_default_credentials.json`

```
#!/bin/sh
set -x

echo "PWD: $(pwd)"
echo "Content: $(ls -al)"

# Remove snapd installed in the container to save some memory.
apt remove --purge -y snapd

# Install latest git, the workers then use git to fetch the repository instead of downloading a tarball.
add-apt-repository --yes ppa:git-core/ppa
apt-get install git -y

# Add the spread group and make spread setgid to that group
groupadd --system --gid 500 spread
cp spread /usr/local/bin/
chown root.spread /usr/local/bin/spread
chmod u=rwx,g=rxs,o=rx /usr/local/bin/spread

# Add gcloud configuration file that is readable only by the spread group
mkdir -p /home/ubuntu/.config/gcloud
cat > /home/ubuntu/.config/gcloud/application_default_credentials.json <<EOF
{
// put your credentials here
}
EOF
chown root.spread /home/ubuntu/.config/gcloud/application_default_credentials.json
chmod u=,g=r,o= /home/ubuntu/.config/gcloud/application_default_credentials.json

# Unpack the runner in the ~ of the ubuntu user
tar -C /home/ubuntu xf actions-runner*.tar.gz
chown -R ubuntu.ubuntu /home/ubuntu/actions-runner
```

Prepare a tarball with the following files. Don’t re-compress it as it’s just a waste of time.
	- `spread`
	- `setup.sh`
	- `actions-runner-linux-x64-2.273.5.tar.gz`

```
mkdir spread-runner
chmod +x setup.sh 
mv setup.sh spread-runner/
mv ~/go/bin/spread spread-runner
mv actions-runner-linux-x64-2.273.5.tar.gz spread-runner/
tar cf spread-runner.tar spread-runner
```

## Creating containers
Spawn a container to familiarize yourself with the process. I used the names spread-1, spread-2, etc for my containers. The name is visible in the GitHub self-hosted worker page that some people have access to (I do not).

```
lxc launch ubuntu:20.04 spread-1
```

Instructions below use `spread-$n` as you can wrap this in a big for loop, to get more workers up quickly.

Make the container auto start on boot. You may also want to start successive containers one after another with a small offset.
```
lxc config set spread-$n boot.autostart true
lxc config set spread-$n boot.autostart.delay 16
```

Copy the tarball  `spread-runner.tar` to the container:

```
lxc file push spread-runner.tar spread-$n/tmp/
```
Unpack the tarball in the container:
```
lxc exec spread-$n -- tar -C /tmp -xf /tmp/spread-runner.tar
```
Run the setup script to „prepare” most of the container.
```
lxc exec spread-$n -- /tmp/spread-runner/setup.sh
```

Registration of the worker is tricky because it requires two _odd_ things: to run as non-root while having sudo *and* to have a valid token that seems to be valid only when someone is looking at the page that displays it.

### Registration and startup

Register your worker with:

```
lxc exec spread-$n -- sudo -u ubuntu -H sh -c "cd ~/actions-runner; ./config.sh --unattended --url https://github.com/snapcore/snapd --token AAG7H4VL7KUDDWQZS5ZSGAS6PJDNU"
```

If this succeeds you’re almost there. If this fails you need to ask Mvo to visit https://github.com/snapcore/snapd/settings/actions and click on the *Add runner* button. Ensure that the token is correct.

Install runner as a service and start it
```
lxc exec spread-$n -- sudo -u ubuntu -H sh -c "cd ~/actions-runner; ./svc.sh install"
lxc exec spread-$n -- sudo -u ubuntu -H sh -c "cd ~/actions-runner; ./svc.sh start"
```

## Hardening
Harden the container by removing root access from the `ubuntu` user:
```
lxc exec spread-$n -- rm -f /etc/sudoers.d/90-cloud-init-users
```

TODO: chown things to prevent the user ubuntu from changing the runner. Some directories need to remain writable (_work and a few others).

## Verification
You should now test the container a little:
```
lxc exec spread-$n — sudo -u ubuntu -H -s
```

- Make sure you cannot use sudo
- Make sure you cannot read `~/.config/gcloud/application_default_credentials.json`
- Make sure you can run spread

You can also reboot the host OS to make sure everything comes back in a working state.

# Putting it all together
```
#!/bin/sh -xe
token=AAG7H4SDGE2FNLFJWXOM5YK6S3HM6
n=${1}

worker=canonistack-a-$n
lxc delete --force "$worker" || true
lxc launch ubuntu:20.04 "$worker"
lxc exec "$worker" -- ls -ld /tmp
lxc config set "$worker" boot.autostart true
lxc config set "$worker" boot.autostart.delay 16
lxc file push spread-runner.tar "$worker"/tmp/spread-runner.tar
lxc exec "$worker" -- tar -C /tmp -xf /tmp/spread-runner.tar
lxc exec "$worker" --cwd /tmp/spread-runner -- /tmp/spread-runner/setup.sh
UID=$(lxc exec canonistack-a-1  -- id -u ubuntu)
lxc exec "$worker" --user "$UID" --cwd /home/ubuntu/actions-runner -- sudo ./config.sh --unattended --url https://github.com/snapcore/snapd --token $token
lxc exec "$worker" --user "$UID" --cwd /home/ubuntu/actions-runner -- sudo ./svc.sh install
lxc exec "$worker" --user "$UID" --cwd /home/ubuntu/actions-runner -- sudo ./svc.sh start
lxc exec "$worker" -- systemctl disable --now ssh.service unattended-upgrades.service networkd-dispatcher.service atd.service cron.service
lxc exec "$worker" -- apt-get clean
lxc exec "$worker" -- rm -rf /tmp/spread-runner{,.tar}
lxc exec "$worker" -- rm -f /etc/sudoers.d/90-cloud-init-users