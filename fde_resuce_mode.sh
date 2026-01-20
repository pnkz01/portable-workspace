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
    echo "Encrypting drive $drive $root $efi with crypt mount $crypt"
else
    echo "Please try with correct drive ids!"
    exit 1
fi

# Run a filesystem check
e2fsck -f "$root"

# install cryptsetup
apt update && apt install cryptsetup -y

# prepare existing filesystem for luks encryption
# Make the filesystem slightly smaller to make space for the LUKS header
BLOCK_SIZE=`dumpe2fs -h $root | grep "Block size" | cut -d ':' -f 2 | tr -d ' '`
BLOCK_COUNT=`dumpe2fs -h $root | grep "Block count" | cut -d ':' -f 2 | tr -d ' '`
SPACE_TO_FREE=$((1024 * 1024 * 32)) # 16MB should be enough, but add a safety margin
NEW_BLOCK_COUNT=$(($BLOCK_COUNT - $SPACE_TO_FREE / $BLOCK_SIZE))
resize2fs -p "$root" "$NEW_BLOCK_COUNT"

# encrypt root
cryptsetup reencrypt --encrypt --reduce-device-size 16M "$root"

# Resize the filesystem to fill up the remaining space (i.e. remove the safety margin from earlier)
cryptsetup open "$root" "$crypt"
resize2fs /dev/mapper/"$crypt"

# Enter chroot mode
mkdir /mnt/"$crypt"
mount /dev/mapper/"$crypt" /mnt/"$crypt"
mount -t proc none /mnt/"$crypt"/proc
mount -t sysfs none /mnt/"$crypt"/sys
mount --bind /dev /mnt/"$crypt"/dev
chroot /mnt/"$crypt"/

echo "Continue inside chroot env"
echo "Please try to reboot into normal mode..."
