#!/bin/bash
set -e

CONT_USER="debaian"
VNC_USER="cries"
VNC_PW="changeme"
PASSWD_PATH="/home/${CONT_USER}/.kasmpasswd"

# Set vnc service
su $CONT_USER -c /bin/bash <<EOF
echo -e "${VNC_PW}\n${VNC_PW}\n" | vncpasswd -u $VNC_USER -w $PASSWD_PATH
chmod 600 $PASSWD_PATH

mkdir -p /home/$CONT_USER/.config/systemd/user
cat << GOF > /home/$CONT_USER/.config/systemd/user/kasmvnc@:1.service
[Unit]
Description=VNC server
After=network-online.target
 
[Service]
Type=forking
Restart=on-failure
ExecStart=vncserver -select-de xfce
ExecStop=vncserver -kill :1

[Install]
WantedBy=default.target
GOF

systemctl --user enable kasmvnc@:1
EOF

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=Computer/OU=CompanySectionName/CN=CommonNameOrHostname"
rm -f /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key
chmod 644 cert.pem
chmod 640 key.pem
chown root:ssl-cert cert.pem key.pem
mv cert.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
mv key.pem /etc/ssl/private/ssl-cert-snakeoil.key

echo "Container image setup commands"
