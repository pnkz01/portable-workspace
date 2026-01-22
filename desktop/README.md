## Setup GUI Desktop using Kasm VNC Docker Container

```
sudo docker compose up -d
sudo docker compose exec vnc bash -c "su debaian -P -c 'bash'"

# Vist https://x.x.x.x:8444 and use login credentials as in cont_setup.sh

```
