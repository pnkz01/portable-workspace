#!/bin/bash

while getopts ":o:n:" opt; do
  case ${opt} in
    o ) old=$OPTARG;;
    n ) new=$OPTARG;;
    \? ) echo "Usage: cmd [-o] debian [-n] dubian";;
  esac
done

if [ -z "$old" ] || [ -z "$new" ]; then
  echo "old, new user names are required."
  exit 1
fi

# Regenerate host keys, only allow few crypt algos
rm /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
echo -e "\nHostKey /etc/ssh/ssh_host_ed25519_key\nHostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config

awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
mv /etc/ssh/moduli.safe /etc/ssh/moduli

echo -e "KexAlgorithms sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,gss-curve25519-sha256-,diffie-hellman-group16-sha512,gss-group16-sha512-,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256\n\nCiphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr\n\nMACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com\n\nHostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nRequiredRSASize 3072\n\nCASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256\n\nGSSAPIKexAlgorithms gss-curve25519-sha256-,gss-group16-sha512-\n\nHostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256\n\nPubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256\n\n" > /etc/ssh/sshd_config.d/hardening.conf

# change default ssh config
sed -i 's/#Port 22/Port 1111/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# add system metrics info to ssh login welcome message
metrics=$(cat <<'EOF'
#!/bin/bash

# Collect system metrics
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}') # Sum of user and system CPU usage
MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }') # Memory usage as a percentage
DISK=$(df -h / | awk 'NR==2 {print $5}') # Root filesystem usage as a percentage
UPTIME=$(uptime -p) # Human-readable uptime
TOP_PROCESSES=$(ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6) # Top 5 processes

# Display the report on the terminal
echo "$(date)"
echo "---------------------------------"
echo "CPU Usage: $CPU%"
echo "Memory Usage: $MEMORY%"
echo "Disk Usage: $DISK"
echo "Uptime: $UPTIME"
echo ""
echo "Top 5 Processes by CPU Usage:"
echo "$TOP_PROCESSES"
echo ""
echo "Current active users"
echo "$(who)"
echo "---------------------------------"

EOF
)

echo "$metrics" > /etc/update-motd.d/10-uname

service ssh restart
service sshd restart

# add new user
sudo useradd -m $new
sudo usermod -aG sudo,adm,dialout,cdrom,floppy,audio,dip,video,plugdev $new
sed -i '$a\'''$new''' ALL=(ALL) NOPASSWD:ALL' /etc/sudoers.d/90-cloud-init-users

sudo cp -r /home/$old/.ssh/ /home/$new/.ssh
sudo chown $new:$new /home/$new/.ssh/
sudo chown $new:$new /home/$new/.ssh/authorized_keys
sudo chsh -s /bin/bash $new

