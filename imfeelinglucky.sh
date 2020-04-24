#!/bin/bash

set -e

timedatectl set-ntp true

hdd=$(fdisk -l | grep 'Disk' | grep '/dev/.da' | awk '{ print $2 }' | sed 's/://')

fdisk $hdd << EOF
n
p
1


w
EOF
part="${hdd}1"
mkfs.ext4 $part

mount $part /mnt

pacstrap /mnt base linux linux-firmware netctl
cp /etc/imfeelinglucky2.sh /mnt/

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

