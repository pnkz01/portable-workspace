#!/bin/bash
set -euo pipefail

while getopts ":d:r:e:" opt; do
  case ${opt} in
    d ) drive=$OPTARG;;
    r ) root=$OPTARG;;
    e ) efi=$OPTARG;;
    \? ) echo "Usage: cmd [-d] sdb [-r] sdb1 [-e] sdb3";;
  esac
done

if [ -z "$drive" ] || [ -z "$root" ] || [ -z "$efi" ]; then
  echo "drive, root, efi are required."
  exit 1
fi

drive="/dev/${drive}"
root="/dev/${root}"
efi="/dev/${efi}"
crypt="root_crypt"

if [[ -b "$drive" ]] && [[ -b "$root" ]] && [[ -b "$efi" ]] ; then
    echo "Fixing grub entries $root $efi $crypt"
else
    echo "Please try with correct drive ids!"
    exit 1
fi

# Inside chrooted environment
mount $efi /boot/efi
lsblk

LUKS_MOUNT_ID="$(blkid -o value -s UUID ${root})"

# change config for automounting cryptroot
sed -i '$a\'"$crypt"' UUID='"$LUKS_MOUNT_ID"' none luks,discard' /etc/crypttab
sed -i "s/.*\/ ext4 .*/\/dev\/mapper\/${crypt} \/ ext4 errors=remount-ro 0 1/" /etc/fstab
sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=${LUKS_MOUNT_ID}:${crypt} root=\/dev\/mapper\/${crypt}\"/" /etc/default/grub

# check files after change
cat /etc/crypttab
cat /etc/fstab
cat /etc/default/grub
diff -u /etc/mtab /proc/mounts

# update grub and initramfs img
grub-install ${drive}
update-initramfs -k all -u  
update-grub
cat /boot/grub/grub.cfg | grep -F "root="

echo "Please exit chroot and reboot into normal mode..."
