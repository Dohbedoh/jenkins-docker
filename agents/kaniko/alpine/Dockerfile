FROM gcr.io/kaniko-project/executor:latest as kaniko
FROM busybox:latest as busybox
# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile

FROM openjdk:8-jre-alpine
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

COPY --from=kaniko /kaniko /kaniko
COPY --from=busybox /bin /busybox

RUN apk add --update --no-cache \
    curl \
    make \
    bash \
    git \
    jq \
    openssh-client

ENV DOCKER_CONFIG /kaniko/.docker/
ENV PATH="${PATH}:/kaniko:/busybox"
ENV SSL_CERT_DIR=/kaniko/ssl/certs

# Declare /busybox as a volume to get it automatically whitelisted
VOLUME /busybox

# The following could be used to preconfigure the image with the ECR docker credentials helper 
# RUN mkdir -p ${DOCKER_CONFIG} && echo '{"credsStore": "ecr-login"}' > ${DOCKER_CONFIG}/config.json
ENV AGENT_WORKDIR=/kaniko/agent
RUN mkdir /kaniko/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /kaniko/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /kaniko
ENTRYPOINT ["/kaniko/executor"]