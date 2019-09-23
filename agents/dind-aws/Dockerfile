FROM docker:18.09.0-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.212.04-r1
ARG AWS_CLI_VERSION=1.16.139
ARG S3_CMD_VERSION=2.0.2

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
  
# Install AWS cli (see https://github.com/alecharp/build-tools/blob/docker-aws/Dockerfile)
RUN apk add --update python py-pip && \
    pip install --no-cache-dir --upgrade pip awscli==$AWS_CLI_VERSION s3cmd==$S3_CMD_VERSION && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

COPY dind-agent-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dind-agent-entrypoint.sh"]