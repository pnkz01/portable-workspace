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
