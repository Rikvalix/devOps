#!/bin/bash

network=ci_network
check_network=$(docker network ls | grep $network)

if [ -n "$check_network" ]; then
    echo "Le réseau ci_network existe déjà."
    exit 0
fi

echo "Création du réseau ci_network"

docker network create $network
docker network connect $network postgresql-postgres-1 
docker network connect $network jenkins-blueocean jenkins-docker 
docker network connect $network jenkins-blueocean 
docker network connect $network jenkins-docker 