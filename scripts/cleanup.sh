#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

# remove cloud-init networking from initial boot
rm /etc/netplan/50-cloud-init.yaml

# reset cloud-init so it can run again
cloud-init clean --logs

# cleanup root access after image setup
sed -i s/^root:[^:]*/root:*/ /etc/shadow
rm -r /root/.ssh
rm -r /root/.cache
rm -r /etc/ssh/ssh_host_*

# clean up packages
apt-get autoremove --purge -yq
apt-get clean -yq
