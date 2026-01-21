# Portable Workspacez

## Initialize Debian Host OS

```
nano os_init.sh

chmod +x os_init.sh

sudo ./os_init.sh

# reboot into resuce mode
sudo reboot now

```


## Setup Full Disc Encryption for debian host (if not using pre encrypted drives)

To unlock disc grub would need TTY access before it boots. If this is cloud host navigate to KVM Panel everytime system reboots to unlock disc.

```
lsblk
fdisk -l
blkid

nano fde_resuce.sh

chmod +x fde_resuce.sh

./fde_rescue.sh -d sda -r sda1 -e sda15

```

After successfull encryption, reboot into main os and check if grub is able to detect crypt drive and unlock.
If not, there might be slight mistake configuring grub bhoot entries.

System will ask password 2 times, 1st by grub to unlock boot partition, then by initramfs to further init the system, feed password through KVM.

## Reboot into main os to Harden SSH

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

sudo systemctl start docker
sudo systemctl status docker
```

## Setup Docker workspace container

Use provided Dockerfile, compose.yaml and setup.sh to setup docker container.

#### Run using docker
```
sudo docker build -t container_bass .
sudo docker run --privileged -it -d --name container_bass container_bass
sudo docker exec -it container_bass /bin/bash -c "su dubian -P -c 'bash'"

# Inside container environment
ls -alh
```

#### Run using docker compose
```
sudo docker compose up -d
sudo docker compose exec container_bass bash -c "su dubian -P -c 'bash'"

# Inside container environment
ls -alh

```

