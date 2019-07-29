FROM node:9.8.0-alpine
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

ARG JRE_VERSION=8.212.04-r0
ARG NPM_VERSION=5.7.0

# Prepare image to be used as Jenkins Agent
RUN apk --update --no-cache add \
  openjdk8-jre=$JRE_VERSION \
  git \
  bzip2 \
  xz \
  nss

RUN npm install -g npm@$NPM_VERSION

RUN mkdir -p /home/node/.m2 && chown -R node:node /home/node/.m2

USER node

WORKDIR /home/node/workspace