#!/usr/bin/env bash

echo services
pacman -Syu
yes | pacman -Sy amd-ucode dhcpcd dhclient

systemctl enable sshd dhcpcd

echo build image
pacman -S lvm2
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot

ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime
hwclock --systohc
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen

echo devKit-$RANDOM-arch > /etc/hostname
echo -e '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 devkit' >> /etc/hosts

groupadd sudo
useradd -m -G sudo g
echo "g ALL=(ALL) ALL" > /etc/sudoers.d/g

passwd g
