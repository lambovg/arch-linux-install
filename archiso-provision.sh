#!/usr/bin/env bash

# echo install zfs module
curl -s https://eoli3n.github.io/archzfs/init | bash

echo parted
parted --script -a opt /dev/vda mklabel gpt mkpart primary 5MB% 512MB mkpart primary 512MB 100% set 1 boot on set 1 esp on

echo zpool setup
# zpool create -f -o ashift=12 \
#     -O acltype=posixacl \
#     -O relatime=on \
#     -O xattr=sa \
#     -O dnodesize=auto \
#     -O normalization=formD \
#     -O mountpoint=none \
#     -O canmount=off \
#     -O devices=off \
#     -R /mnt \
#     zroot /dev/vda2

zpool create -f -o ashift=12 \
    -O acltype=posixacl \
    -O canmount=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O atime=off \
    -O xattr=sa \
    -O mountpoint=none \
    -R /mnt \
    zroot /dev/vda2

zfs create -o mountpoint=none zroot/data
zfs create -o mountpoint=none zroot/ROOT
zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/default
zfs create -o mountpoint=/home zroot/data/home

# zfs create -o canmount=noauto -o mountpoint=/ zroot/rootfs
# zfs create -o mountpoint=/home zroot/rootfs/home

setopt RM_STAR_SILENT
zfs unmount -a
rm -rf /mnt/*
zfs mount zroot/ROOT/default

echo cache
mkdir -p /mnt/etc/zfs
zpool set cachefile=/etc/zfs/zpool.cache zroot
cp /etc/zfs/zpool.cache /mnt/etc/zfs/zpool.cache

# echo create root partition
# mkfs.ext4 /dev/vda2
# mount /dev/vda2 /mnt

echo create boot partition
mkfs.vfat /dev/vda1
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

echo filesystem table
genfstab -U -p /mnt >>/mnt/etc/fstab

echo basic system setup
sed -i -e 's/CheckSpace/#CheckSpace/' /etc/pacman.conf
pacstrap /mnt base base-devel linux linux-headers linux-firmware \
    grub zsh vim efibootmgr openssh tmux git gnupg rsync wget curl sudo
