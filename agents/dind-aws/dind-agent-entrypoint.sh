#!/bin/sh
# Optional environment variables :
# * DOCKER_OPTS : Docker options to add to the docker daemon

set -eu

DOCKER_OPTS="${DOCKER_OPTS:-}"

echo "Starting the Docker daemon..."
/usr/local/bin/dockerd-entrypoint.sh ${DOCKER_OPTS} >/docker.log 2>&1 &
    
while(! docker info > /dev/null 2>&1); do
  echo "Waiting for the Docker daemon to start..."
  sleep 1
done

echo "Docker Daemon started"

exec "$@"