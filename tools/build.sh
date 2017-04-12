#!/bin/bash

docker-compose \
    -f compose/python-commons.yml \
    up --build -d

docker-compose \
    -f compose/common.yml \
    -f compose/pro.yml \
    -f compose/build.yml \
    build

 docker images | \
     grep $DOCKER_REGISTRY | \
     awk '{print $1}' | \
     xargs -P 0 -I {} docker push {}

