# Portable Workspacez

## Initialize Debian Host VM

```
nano os_init.sh

chmod +x os_init.sh

sudo ./os_init.sh

# list system resources
ip addr
ss -tulpn
lsblk
df -h
sudo blkid
free -mh
ps -ef

# reboot into resuce mode
sudo reboot now

```


## Setup Full Disc Encryption, if not using pre encrypted disc

Follow steps provided in fde.md or run below command after rebooting into rescue mode.

To unlock discs grub would need TTY access before it boots. If this is cloud host navigate to KVM Panel everytime system reboots.

```
nano fde_resuce_mode.sh

blkid

chmod +x fde_resuce_mode.sh

./fde_rescue_mode.sh -d sdb -r sdb1 -e sdb2

```

After successfull encryption and reboot, follow next steps.
If not, there might be slight mistake configuring grub bhoot entries.


## Harden SSH

```
nano hard_sh_ssh.sh
chmod +x hard_sh_ssh.sh
  
sudo ./hard_sh_ssh.sh -o debian -n dubian

# login as a new user ink a nwe shell, check if everything is working ass fine.
# Reboot, login as a new user in a new system.
# Delete old user, remove any unremoved hanging entries

sudo userdel -r debian
sudo visudo /etc/sudoers.d/90-cloud-init-users

# Change or add new add key
sudo nano ~/.ssh/authorized_keys


```

## Install Docker
https://docs.docker.com/engine/install/debian/

```
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl status docker
```

## Setup Docker workspace container

Use provided Dockerfile, compose.yaml and setup.sh to setup GUI docker container.

#### Run using docker
```
sudo docker build -t dubian .
sudo docker run --privileged -it -d -p 8444:8444 --name dubian dubian
sudo docker exec -it dubian /bin/bash

# Inside container environment
su dubian
bash
vncserver -select-de xfce

# Visit url provided by vncserver
```

#### Run using docker compose
```
sudo docker compose up -d
sudo docker compose exec vnc bash -c "su dubian -P -c 'bash'"

# Inside container environment
vncserver -select-de xfce

# Visit url provided by vncserver


```

