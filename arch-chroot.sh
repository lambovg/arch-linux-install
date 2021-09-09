#!/usr/bin/env bash

echo -e '
[archzfs]
Server = https://archzfs.com/$repo/x86_64' >> /etc/pacman.conf

# ArchZFS GPG keys (see https://wiki.archlinux.org/index.php/Unofficial_user_repositories#archzfs)
pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76

pacman -Sy zfs-dkms amd-ucode

systemctl enable sshd

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot

systemctl enable zfs.target zfs-import-cache \
  zfs-mount zfs-import.target

ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime # Change according to location…
hwclock --systohc # Sync with HW clock

echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

echo devKit > /etc/hostname
echo -e '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 devkit' >> /etc/hosts

groupadd sudo
useradd -m -G sudo g