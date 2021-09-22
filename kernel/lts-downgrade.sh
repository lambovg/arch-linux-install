INST_LINVAR=linux-lts
DKMS_DATE=$(pacman -Syi zfs-dkms |
    grep 'Build Date' |
    sed 's/.*: //' |
    LC_ALL=C xargs -i{} date -d {} -u +%Y/%m/%d)
INST_LINVER=$(curl https://archive.archlinux.org/repos/${DKMS_DATE}/core/os/x86_64/ |
    grep \"${INST_LINVAR}-'[0-9]' |
    grep -v sig |
    sed "s|.*$INST_LINVAR-||" |
    sed "s|-x86_64.*||")
pacman -U \
    https://archive.archlinux.org/packages/l/${INST_LINVAR}/${INST_LINVAR}-${INST_LINVER}-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/${INST_LINVAR}-headers/${INST_LINVAR}-headers-${INST_LINVER}-x86_64.pkg.tar.zst


mount /dev/vda1 /mnt
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/mnt

sed -i 's/#IgnorePkg/IgnorePkg/' /etc/pacman.conf
sed -i "/^IgnorePkg/ s/$/ ${INST_LINVAR} ${INST_LINVAR}-headers/" /etc/pacman.conf

reboot