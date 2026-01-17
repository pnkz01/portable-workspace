#!/bin/bash
# list system resources
ip addr
ss -tulpn
lsblk
df -h
sudo blkid
free -mh
ps -ef

# os env init
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential htop cryptsetup cryptsetup-initramfs

# disable non required services
sudo sed -i 's/#LLMNR=yes/LLMNR=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
