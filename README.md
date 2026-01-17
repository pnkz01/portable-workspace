# Portable Workspacez

## Initialize Debian Host VM

```
./os_init.sh

sudo reboot now

```


## Setup Full Disc Encryption, if not using pre encrypted disc

Follow steps provided in fde.md or run below command after rebooting into rescue mode.

To unlock discs grub would need TTY access before it boots. If this is cloud host navigate to KVM Panel everytime system reboots.

```
./fde_rescue.sh -d sdb -r sdb1 -e sdb2

```

After successfull encryption and reboot, follow next steps.
If not, there might be slight mistake configuring grub bhoot entries.


## Harden SSH

```
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

## Setup Docker workspace container

Use provided Dockerfile, compose.yaml and setup scripts to setup GUI docker container.

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
sudo docker compose exec vnc bash

# Inside container environment
su dubian
bash
vncserver -select-de xfce

# Visit url provided by vncserver


```

