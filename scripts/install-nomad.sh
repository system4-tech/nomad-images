#!/bin/bash -ex

# install required packages
apt-get update && apt-get install wget gpg coreutils

# add hashicorp gpg key
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# add hashicorp linux repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| tee /etc/apt/sources.list.d/hashicorp.list

# update and install nomad
# todo: support versioning
apt-get update && apt-get install -y nomad
