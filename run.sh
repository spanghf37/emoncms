#!/bin/bash 
#install emoncms
git clone https://github.com/spanghf37/emoncms.git ./emoncms-docker
git clone https://github.com/emoncms/emoncms.git ./emoncms
git clone https://github.com/emoncms/dashboard.git ./emoncms/Modules/dashboard
git clone https://github.com/emoncms/graph.git ./emoncms/Modules/graph

# Use docker settings
cp  docker.settings.php ./emoncms/settings.php

cd emoncms-docker
docker pull spanghf37/emoncms:latest
docker-compose up
docker ps
