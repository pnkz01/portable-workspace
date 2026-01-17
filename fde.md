# Full Disk Encryption after debian install

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

## Run fde_pre.sh in main os
```
./fde_pre.sh
```
After script executes, reboot into resuce mode.


## Run fde_rescue_mode_init.sh after logging into rescue mode
```
./fde_rescue_mode_init.sh /dev/sdb1
```
This script encrypt provided drive using luks


## Run fde_rescue_chroot.sh to chroot into original system
```
./fde_rescue_chroot.sh
```

## Run fde_rescue_chroot_post.sh to change boot entries
```
./fde_rescue_chroot_post.sh
```

## Run fde_rescue_chroot_exit.sh to exit chroot session safely
```
exit # from current chroot session

./fde_rescue_chroot_exit.sh
```

## Reboot into main os, system will ask password 2 times
1st by grub to unlock boot partition,
then by initramfs to further init the system,
feed password through KVM

