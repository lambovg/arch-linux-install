#!/usr/bin/env bash

echo install zfs module
curl -s https://eoli3n.github.io/archzfs/init | bash

echo parted
parted --script /dev/vda mklabel gpt mkpart primary 5MB% 512MB mkpart primary 512MB 100%  set 1 boot on set 1 esp on
