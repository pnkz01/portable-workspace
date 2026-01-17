#!/bin/bash

# enable crytpodisk in grub
sudo sed -i '$a\GRUB_ENABLE_CRYPTODISK=y' /etc/default/grub
sudo cat /etc/default/grub

# check correct keyboard layout in /etc/default/keyboard
sudo cat /etc/default/keyboard

sudo update-initramfs -u
# check that the cryptsetup is installed in initramfs
lsinitramfs /boot/initrd.img-$(uname -r) | grep crypt
