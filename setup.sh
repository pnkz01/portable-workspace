#!/bin/bash
set -e

# Set vnc user
PASSWD_PATH="/home/dubian/.kasmpasswd"
VNC_PW="wassup02-4"

echo -e "${VNC_PW}\n${VNC_PW}\n" | vncpasswd -u grutmeme -wo $PASSWD_PATH
echo -e "${VNC_PW}\n${VNC_PW}\n" | vncpasswd -u dub_user -r $PASSWD_PATH

chmod 600 $PASSWD_PATH
chown 1000:1000 $PASSWD_PATH
