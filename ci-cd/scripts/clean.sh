#!/bin/bash

echo "Protocole clean"

echo "Jenkins"

docker rm -f jenkins-blueocean jenkins-docker 2>/dev/null || true
docker rmi -f jenkins-blueocean jenkins-docker 2>/dev/null || true
docker network rm jenkins 2>/dev/null || true
