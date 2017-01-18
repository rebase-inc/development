#!/bin/bash

docker-compose -f compose/common.yml -f compose/pro.yml config | grep alpha | awk '{ print $2 }' | xargs -I {} docker push {}
