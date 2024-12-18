#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive

# update package list since it could be stale
apt-get update -q

# remove cloud image kernel so we can install a generic kernel
apt-get remove --purge -y linux-virtual 'linux-image-*'
