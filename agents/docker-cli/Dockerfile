#################
# Tools Builder #
#################
FROM golang:1.16 as builder

# equivalent to `uname -s`
ARG OSNAME=linux
ARG OSARCH=amd64

# Tools Versions
ARG DOCKER_VERSION=20.10.6
ARG DOCKER_COMPOSE_VERSION=1.27.2
ARG DOCKER_GCR_VERSION=2.0.4
ARG DOCKER_ECR_VERSION=0.5.0

USER root

# Need xz and zip for extracting and repackaging some archives
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Where to hold tools binaries (equivalent to target /usr/local/)
RUN mkdir -p /tools/bin

# Get docker CLI
RUN curl -fsSL https://download.docker.com/${OSNAME}/static/stable/`uname -m`/docker-${DOCKER_VERSION}.tgz | \
    tar --no-same-owner --strip-components=1 -xz -C /tools/bin docker/docker && \
    chmod a+x /tools/bin/docker

# Get docker-compose CLI
RUN curl -fsSL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /tools/bin/docker-compose && \
    chmod a+x /tools/bin/docker-compose

# Get GCR credential helper
RUN curl -fsSL https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${DOCKER_GCR_VERSION}/docker-credential-gcr_${OSNAME}_${OSARCH}-${DOCKER_GCR_VERSION}.tar.gz | \
    tar --no-same-owner -xz -C /tools/bin && \
    chmod a+x /tools/bin/docker-credential-gcr
# Or from source:
#RUN go get -u github.com/GoogleCloudPlatform/docker-credential-gcr
#RUN make -C /go/src/github.com/GoogleCloudPlatform/docker-credential-gcr && \
#    mv /go/src/github.com/GoogleCloudPlatform/docker-credential-gcr/bin/docker-credential-gcr /tools/bin/docker-credential-gcr

# Get Amazon ECR credential helper
RUN curl -fsSL https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/${DOCKER_ECR_VERSION}/${OSNAME}-${OSARCH}/docker-credential-ecr-login -o /tools/bin/docker-credential-ecr-login && \
    chmod a+x /tools/bin/docker-credential-ecr-login
# Or from source:
#RUN go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
#RUN make -C /go/src/github.com/awslabs/amazon-ecr-credential-helper ${OSNAME}-${OSARCH}  && \
#    mv /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/${OSNAME}-${OSARCH}/docker-credential-ecr-login /tools/bin/docker-credential-ecr-login

###############
# Agent Image #
###############

FROM jenkins/inbound-agent:latest-jdk11
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

ARG user=jenkins

USER root

################
# Common Tools #
################

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    # Following already exists in the base image jenkins/agent
#    git \
#    bash \
#    openssh-client \
    curl \
    xz-utils \
    zip \
    unzip \
    bzip2

#######################
# Docker Client Tools #
#######################

# ADD Docker tools and set env variables

COPY --from=builder /tools/bin/docker-compose /usr/local/bin/docker-compose
COPY --from=builder /tools/bin/docker /usr/local/bin/docker
COPY --from=builder /tools/bin/docker-credential-gcr /usr/local/bin/docker-credential-gcr
COPY --from=builder /tools/bin/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login

###################
# Fix permissions #
###################

# Running tool commands such as `<tool> version` creates some cache directories under $HOME (/home/jenkins)
RUN chown -R ${user}:${user} ${HOME}

##############################
# Jenkins user configuration #
##############################

USER ${user}

#######################
# Docker Client Tools #
#######################

RUN mkdir -p $HOME/.docker
RUN docker-credential-gcr configure-docker