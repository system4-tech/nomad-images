#!/bin/bash -ex

# update packages and install generic kernel
apt-get update
apt-get install -y linux-image-generic linux-headers-generic

# update grub to use the new kernel
update-grub
