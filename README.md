# Portable Workspace

## Setup Host VM
```
./os_init.sh
sudo reboot now
```

## Setup FDE
Follow steps provided in fde.md

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

