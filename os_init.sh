#!/bin/bash

# os env init
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential htop cryptsetup cryptsetup-initramfs

# disable non required services
sudo sed -i 's/#LLMNR=yes/LLMNR=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

# Prepare os for fde
# enable crytpodisk in grub
sudo sed -zi '/GRUB_ENABLE_CRYPTODISK=y/!s/$/\nGRUB_ENABLE_CRYPTODISK=y\n/' /etc/default/grub
sudo cat /etc/default/grub

# check if correct keyboard layout is set in /etc/default/keyboard
sudo cat /etc/default/keyboard

sudo update-initramfs -u
# check that the cryptsetup is installed in initramfs
lsinitramfs /boot/initrd.img-$(uname -r) | grep crypt

# list system resources
echo "----------------------------"
ip addr
ss -tulpn
lsblk
df -h
sudo blkid
free -mh
ps -ef
