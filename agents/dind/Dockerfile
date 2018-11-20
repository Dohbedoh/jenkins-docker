FROM docker:18.09.0-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.181.13-r0

# Prepare image to be used as Jenkins Agent
RUN apk --update --no-cache add \
  openjdk8-jre=$JRE_VERSION \
  git \
  make

COPY dind-agent-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dind-agent-entrypoint.sh"]