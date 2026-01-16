# portable workspace

# Run using docker
sudo docker build -t dubian .
sudo docker run --privileged -it -d -p 8444:8444 --name dubian dubian
sudo docker exec -it dubian /bin/bash

# Using docker compose
sudo docker compose up -d
sudo docker compose exec vnc bash


