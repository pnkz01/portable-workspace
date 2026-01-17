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

# Run a filesystem check
e2fsck -f "$drive"
e2fsck -f "$root"
e2fsck -f "$efi"

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

# PBKDF:      pbkdf2
# should be pbkdf2 not argon2id for grub to unlock using correct key format
# This should be fixed and not needed for newer grub versions
cryptsetup luksDump "$root"
cryptsetup luksConvertKey --pbkdf pbkdf2 "$root"
cryptsetup luksDump "$root"
cryptsetup --verbose open --test-passphrase "$root"

# Enter chroot mode
mkdir /mnt/"$crypt"
mount /dev/mapper/"$crypt" /mnt/"$crypt"
mount -t proc none /mnt/"$crypt"/proc
mount -t sysfs none /mnt/"$crypt"/sys
mount --bind /dev /mnt/"$crypt"/dev
chroot /mnt/"$crypt"/

# Inside chrooted environment
mount $efi /boot/efi
lsblk

LUKS_MOUNT_ID="$(blkid -o value -s UUID ${crypt})"

# change config for automounting cryptroot
sed -i '$a\'"$crypt"' UUID='"$LUKS_MOUNT_ID"' none luks,discard' /etc/crypttab
sed -i 's/.*\/ ext4 .*/\/dev\/mapper\/'"$crypt"' \/ ext4 errors=remount-ro 0 1/' /etc/fstab
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

# Exit chroot
exit

# Inside rescue enviroment
umount /mnt/${crypt}/proc
umount /mnt/${crypt}/sys
umount /mnt/${crypt}/dev
umount /mnt/${crypt}/boot/efi
umount /mnt/${crypt}
cryptsetup close ${crypt}
rmdir -v /mnt/${crypt}

echo "Please try to reboot into normal mode..."
