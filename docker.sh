#!/bin/bash

# build the image
docker build -t curtesmith/my-hello-world:latest .

# authenticate to docker hub
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin

# push the image to docker hub
docker push curtesmith/my-hello-world:latest