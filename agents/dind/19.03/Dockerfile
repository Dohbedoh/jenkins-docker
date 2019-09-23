FROM docker:19.03-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.212.04-r1

# Prepare image to be used as Jenkins Agent
# TODO Remove NSS when fix for https://github.com/docker-library/openjdk/issues/289 is released
RUN apk --update --no-cache add \
  openjdk8-jre=$JRE_VERSION \
  curl \
  git \
  jq \
  make \
  openssh-client \
  nss

COPY dind-agent.sh /usr/local/bin/

ENTRYPOINT ["dind-agent.sh"]