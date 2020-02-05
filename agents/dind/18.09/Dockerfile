FROM docker:18.09-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.242.08-r0

# Prepare image to be used as Jenkins Agent
# TODO Remove NSS when fix for https://github.com/docker-library/openjdk/issues/289 is released
RUN apk --update --no-cache add \
  openjdk8-jre=$JRE_VERSION \
  curl \
  git \
  jq \
  bash \
  make \
  openssh-client \
  nss

COPY dind-agent-entrypoint.sh /usr/local/bin/

ENV AGENT_WORKDIR=/root/agent
RUN mkdir /root/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /root/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /root

ENTRYPOINT ["dind-agent-entrypoint.sh"]