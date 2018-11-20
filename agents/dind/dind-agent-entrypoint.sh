#!/bin/sh
# Optional environment variables :
# * DOCKER_OPTS : Docker options to add to the docker daemon

set -e

if [ "$#" -eq 0 ]; then
    # See https://github.com/docker-library/docker/blob/master/18.09/dind/dockerd-entrypoint.sh
    set -- dockerd \
		    --host=unix:///var/run/docker.sock \
		    --host=tcp://0.0.0.0:2375 \
		    "$@"
else 
    # See https://github.com/mesosphere/dcos-jenkins-dind-agent/blob/master/wrapper.sh
    echo "Starting the Docker daemon..."
    sh "$(which dind)" dockerd \
        --host=unix:///var/run/docker.sock \
        --host=tcp://0.0.0.0:2375 \
        $DOCKER_OPTS &
    
    while(! docker info > /dev/null 2>&1); do
        echo "Waiting for the Docker daemon to start..."
        sleep 1
    done
    
    echo "Docker Daemon started"
fi
    
exec "$@"