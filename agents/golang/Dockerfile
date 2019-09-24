FROM golang:1.11-stretch
# https://github.com/docker-library/golang/blob/master/1.11/stretch
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

ARG JRE_VERSION=8u222-b10-1~deb9u1

ENV HOME /home/jenkins
RUN groupadd -g 1000 jenkins && \
    useradd -c "Jenkins" -d $HOME -u 1000 -g 1000 -m jenkins

# Prepare image to be used as Jenkins Agent
RUN apt-get update && \
    apt-get install -y \
    openjdk-8-jre="$JRE_VERSION" \
    jq \
    && rm -rf /var/lib/apt/lists/*

USER jenkins
ENV AGENT_WORKDIR=/home/jenkins/agent
RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/jenkins/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}