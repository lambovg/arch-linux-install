#!/usr/bin/env bash

echo parted
parted --script -a opt /dev/vda mklabel gpt mkpart primary 5MB% 512MB mkpart primary 512MB 100% set 1 boot on set 1 esp on

echo create root partition
mkfs.ext4 /dev/vda2
mount /dev/vda2 /mnt

echo boot partition
mkfs.vfat /dev/vda1
mkdir -p /mnt/boot
mount /dev/vda1 /mnt/boot

echo fstab
mkdir -p /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab

echo basic system setup
sed -i -e 's/CheckSpace/#CheckSpace/' /etc/pacman.conf
pacstrap /mnt base base-devel linux linux-headers linux-firmware \
    grub zsh vim efibootmgr openssh tmux git gnupg rsync wget curl sudo

 df -hT

 arch-chroot /mnt