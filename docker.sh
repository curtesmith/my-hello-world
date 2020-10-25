#!/bin/bash

docker build -t curtesmith/my-hello-world:latest .
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
docker push curtesmith/my-hello-world:latest