## Setup GUI Desktop Container

Using Kasm VNC Docker Container

```
sudo docker compose up -d
sudo docker compose exec vnc bash -c "su debaian -P -c 'bash'"

# Vist https://x.x.x.x:8444 and use login credentials as in cont_setup.sh

# To debug any issues with kasm vnc, run inside container user
tail -f ~/.vnc/*.log

```


## Bonus

Reset docker

```
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
sudo docker volume rm $(sudo docker volume ls -q)

sudo docker rmi $(sudo docker images -a -q)
sudo docker system prune -a -f --volumes

# Stop all running socker containers
# Remove all containers
# Remove all docker volumes

# Remove all container images
# Reset docker system

```
