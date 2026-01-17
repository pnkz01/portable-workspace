# Portable Workspace

## Setup Host VM
```
./os_init.sh
sudo reboot now
```

## Setup FDE
Follow steps provided in fde.md

## Change default user
```
./add_new_user.sh

# login as new user ink nwe shell, check if everything is working fine.
# Reboot, login as new user in new system.
# Delete old user, remove any unremoved entries

sudo userdel -r debian
sudo visudo /etc/sudoers.d/90-cloud-init-users

```


## Install docker
https://docs.docker.com/engine/install/debian/

## Setup docker container
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

