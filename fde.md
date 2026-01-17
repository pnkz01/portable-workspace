# Full Disk Encryption after debian install [Need KVM access to unlock disc]

## Check original disk & file structure
```
lsblk
df -h
sudo blkid
cat /proc/mounts 
cat /etc/mtab 
cat /etc/fstab 
cat /etc/crypttab
cat /etc/default/grub
```

## Run fde_rescue_mode_init.sh after logging into rescue mode
```
./fde_rescue_mode_init.sh /dev/sdb1
```

```
#!/bin/bash
set -euo pipefail

# prepare existing filesystem for luks encryption
DISK="${1:-}"

if [ -z "$DISK" ]; then
        echo "Usage: $0 /dev/sdXY"
        exit 1
fi

# Run a filesystem check
e2fsck -f "$DISK"

# install cryptsetup
apt update && apt install cryptsetup -y

# Make the filesystem slightly smaller to make space for the LUKS header
BLOCK_SIZE=`dumpe2fs -h $DISK | grep "Block size" | cut -d ':' -f 2 | tr -d ' '`
BLOCK_COUNT=`dumpe2fs -h $DISK | grep "Block count" | cut -d ':' -f 2 | tr -d ' '`
SPACE_TO_FREE=$((1024 * 1024 * 32)) # 16MB should be enough, but add a safety margin
NEW_BLOCK_COUNT=$(($BLOCK_COUNT - $SPACE_TO_FREE / $BLOCK_SIZE))
resize2fs -p "$DISK" "$NEW_BLOCK_COUNT"

# encrypt disk
cryptsetup reencrypt --encrypt --reduce-device-size 16M "$DISK"

# Resize the filesystem to fill up the remaining space (i.e. remove the safety margin from earlier)
cryptsetup open "$DISK" recrypt
resize2fs /dev/mapper/recrypt
cryptsetup close recrypt

# PBKDF:      pbkdf2
# should be pbkdf2 not argon2id for grub to unlock using correct key format
cryptsetup luksDump "$DISK"
cryptsetup luksConvertKey --pbkdf pbkdf2 "$DISK"
cryptsetup luksDump "$DISK"
cryptsetup --verbose open --test-passphrase "$DISK"
```

This script encrypt provided drive using luks. Enter your desired password multiple times.


## Run fde_rescue_chroot.sh to chroot into main system
```
./fde_rescue_chroot.sh
```

```
#!/bin/bash
DEVICE_NAME="root_crypt"
DEVICE_MOUNT="/dev/sdb1"

cryptsetup open ${DEVICE_MOUNT} ${DEVICE_NAME}
mkdir /mnt/${DEVICE_NAME}
mount /dev/mapper/${DEVICE_NAME} /mnt/${DEVICE_NAME}
mount -t proc none /mnt/${DEVICE_NAME}/proc
mount -t sysfs none /mnt/${DEVICE_NAME}/sys
mount --bind /dev /mnt/${DEVICE_NAME}/dev
chroot /mnt/${DEVICE_NAME}/
```


## Run fde_rescue_chroot_post.sh to change boot entries
```
./fde_rescue_chroot_post.sh
```

```
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
```

This script modifies grub, crypttab, fstab entries.

## Run fde_rescue_chroot_exit.sh to exit chroot session safely
```
exit # from current chroot session

./fde_rescue_chroot_exit.sh
```

```
#!/bin/bash
DEVICE_NAME="root_crypt"
umount /mnt/${DEVICE_NAME}/proc
umount /mnt/${DEVICE_NAME}/sys
umount /mnt/${DEVICE_NAME}/dev
umount /mnt/${DEVICE_NAME}/boot/efi
umount /mnt/${DEVICE_NAME}
cryptsetup close ${DEVICE_NAME}
rmdir -v /mnt/${DEVICE_NAME}

echo "Please reboot into normal mode"
```

## Reboot into main os
Reboot into main vm and check if grub is able to detect crypt volume and unlock.

System will ask password 2 times, 1st by grub to unlock boot partition,
then by initramfs to further init the system,
feed password through KVM.

