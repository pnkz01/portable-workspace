#!/bin/bash

GRUB_MOUNT="/dev/sdb"
LUKS_MOUNT="/dev/sdb1"
EFI_MOUNT="/dev/sdb15"
LUKS_MOUNT_ID="$(blkid -o value -s UUID ${LUKS_MOUNT})"

mount $EFI_MOUNT /boot/efi
lsblk

# change config for automounting cryptdisk
sed -i '$a\root_crypt UUID='"$LUKS_MOUNT_ID"' none luks,discard' /etc/crypttab
sed -i 's/.*\/ ext4 .*/\/dev\/mapper\/root_crypt \/ ext4 errors=remount-ro 0 1/' /etc/fstab
sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=${LUKS_MOUNT_ID}:root_crypt root=\/dev\/mapper\/root_crypt\"/" /etc/default/grub

# check files after change
cat /etc/crypttab
cat /etc/fstab
cat /etc/default/grub
diff -u /etc/mtab /proc/mounts

# update grub and initramfs img
grub-install ${GRUB_MOUNT}
update-initramfs -k all -u  
update-grub
cat /boot/grub/grub.cfg | grep -F "root="
