#!/usr/bin/env bash

echo -e '
[archzfs]
Server = https://archzfs.com/$repo/x86_64' >> /etc/pacman.conf

# ArchZFS GPG keys (see https://wiki.archlinux.org/index.php/Unofficial_user_repositories#archzfs)
pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76

pacman -Syu
yes | pacman -Sy zfs-dkms amd-ucode
yes | pacman -Sy dhcpcd dhclient

systemctl enable sshd dhcpcd

echo build image
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block zfs filesystems keyboard fsck)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot

systemctl enable zfs.target zfs-import-cache \
  zfs-mount zfs-import.target

ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime
hwclock --systohc
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

echo devKit > /etc/hostname
echo -e '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 devkit' >> /etc/hosts

groupadd sudo
useradd -m -G sudo g
echo "g ALL=(ALL) ALL" > /etc/sudoers.d/g