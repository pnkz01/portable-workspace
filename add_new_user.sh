#!/bin/bash

OLDUSER="debian"
NEWUSER="hoahwoahsuyou"

sudo useradd -m $NEWUSER
sudo usermod -aG sudo,adm,dialout,cdrom,floppy,audio,dip,video,plugdev $NEWUSER
sed -i '$a\'''$NEWUSER''' ALL=(ALL) NOPASSWD:ALL' /etc/sudoers.d/90-cloud-init-users

sudo cp -r /home/$OLDUSER/.ssh/ /home/$NEWUSER/.ssh
sudo chown $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh/
sudo chown $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh/authorized_keys

sudo chsh -s /bin/bash $NEWUSER
