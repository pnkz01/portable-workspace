# Portable Workspace

## Setup Host VM
```
./os_init.sh

sudo reboot now
```

## Setup FDE
Follow steps provided in fde.md


After successfull encryption and reboot, follow next steps

## Change default user
```
./add_new_user.sh

# login as new user ink nwe shell, check if everything is working fine.
# Reboot, login as new user in new system.
# Delete old user, remove any unremoved entries

sudo userdel -r debian
sudo visudo /etc/sudoers.d/90-cloud-init-users

```

## Harden SSH
```
sudo ./hard_sh_ssh.sh

# Change or add new add key
sudo nano ~/.ssh/authorized_keys

```

## Customise SSH after login message, if needed
Follow ssh_after_login_metrics.md

## Install docker
https://docs.docker.com/engine/install/debian/

## Setup docker container

Use provided Dockerfile, compose.yaml and setup scripts to setup gui docker container.

### Run using docker
```
sudo docker build -t dubian .
sudo docker run --privileged -it -d -p 8444:8444 --name dubian dubian
sudo docker exec -it dubian /bin/bash
```

### Run using docker compose
```
sudo docker compose up -d
sudo docker compose exec vnc bash
```

