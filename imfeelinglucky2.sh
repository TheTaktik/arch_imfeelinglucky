#!/bin/bash

set -e

hdd=$(fdisk -l | grep 'Disk' | grep '/dev/.da' | awk '{ print $2 }' | sed 's/://')

num_tz=$(find /usr/share/zoneinfo/ | grep -v '\.' | grep -v '/$' | wc -l)
tz_line=$(($(($RANDOM % $num_tz)) + 1))
tz=$(find /usr/share/zoneinfo/ | grep -v '\.' | grep -v '/$' | sed "${tz_line}p;d")

timedatectl set-ntp true
ln -sf $tz /etc/localtime
hwclock --systohc

sed -e 's/^\([^#]\)/#\1/' /etc/locale.gen > /etc/locale.gen.bak
locale_line=$(($(($RANDOM % $(cat /etc/locale.gen.bak | wc -l))) + 1))
sed "${locale_line}s/^#//" /etc/locale.gen.bak > /etc/locale.gen
locale=$(cat /etc/locale.gen | grep '^[^#]' | awk '{print $1}')
locale-gen
echo "LANG=${locale}" > /etc/locale.conf

keyboard_lines=$(($(($RANDOM % $(localectl list-keymaps | wc -l))) + 1))
keyboard_layout=$(localectl list-keymaps | sed "${keyboard_lines}q;d")
loadkeys $keyboard_layout
echo "KEYMAP=${keyboard_layout}" > /etc/vconsole.conf

# TODO network

passwd << EOF
root
root
EOF

pacman -S grub << EOF
y
EOF

grub-install --target=i386-pc $hdd
grub-mkconfig -o /boot/grub/grub.cfg

echo $locale
echo $keyboard_layout
echo $tz
echo "Have fun"
