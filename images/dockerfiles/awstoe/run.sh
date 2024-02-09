#!/usr/bin/env bash

# run the docker-compose file in this folder in the background,
# then docker exec into the running container called "awstoe-1"
# interrupting this script will stop the container

export DOCKER_DEFAULT_PLATFORM=linux/x86_64
CONTAINER_REF=$(docker-compose run --rm -d awstoe)

echo "Container reference: $CONTAINER_REF"
docker exec -it $CONTAINER_REF /bin/bash && docker-compose stop