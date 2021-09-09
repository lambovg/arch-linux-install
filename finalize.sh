#!/usr/bin/env bash

exit

umount -R /mnt
zfs umount -a
zpool export -a