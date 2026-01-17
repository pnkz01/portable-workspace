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

# change default ssh config
sudo sed -i 's/#Port 22/Port 1111/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# disable non required services
sudo sed -i 's/#LLMNR=yes/LLMNR=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
