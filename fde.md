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

## Run fde_pre.sh in main os
```
./fde_pre.sh
```
This script prepare the host vm for enryption.

After script executes, reboot into resuce mode.


## Run fde_rescue_mode_init.sh after logging into rescue mode
```
./fde_rescue_mode_init.sh /dev/sdb1
```
This script encrypt provided drive using luks. Enter your desired password multiple times.


## Run fde_rescue_chroot.sh to chroot into main system
```
./fde_rescue_chroot.sh
```

## Run fde_rescue_chroot_post.sh to change boot entries
```
./fde_rescue_chroot_post.sh
```
This script modifies grub, crypttab, fstab entries.

## Run fde_rescue_chroot_exit.sh to exit chroot session safely
```
exit # from current chroot session

./fde_rescue_chroot_exit.sh
```

## Reboot into main os
Reboot into main vm and check if grub is able to detect crypt volume and unlock.

System will ask password 2 times, 1st by grub to unlock boot partition,
then by initramfs to further init the system,
feed password through KVM.

