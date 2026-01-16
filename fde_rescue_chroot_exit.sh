DEVICE_NAME="root_crypt"
umount /mnt/${DEVICE_NAME}/proc
umount /mnt/${DEVICE_NAME}/sys
umount /mnt/${DEVICE_NAME}/dev
umount /mnt/${DEVICE_NAME}/boot/efi
umount /mnt/${DEVICE_NAME}
cryptsetup close ${DEVICE_NAME}
rmdir -v /mnt/${DEVICE_NAME}

echo "Please reboot into normal mode"
