FROM jenkins/slave:alpine
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

ARG ANCHORE_CLI_VERSION=0.5.0

USER root
RUN apk add --update --no-cache \
    curl \
    make \
    bash \
    git \
    jq \
    openssh-client

RUN apk add --update python py-pip && \
    pip install --no-cache-dir --upgrade pip anchorecli==$ANCHORE_CLI_VERSION && \
    rm /var/cache/apk/*

USER jenkins