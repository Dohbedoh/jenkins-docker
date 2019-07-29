FROM gcr.io/kaniko-project/executor:latest as kaniko
FROM busybox:latest as busybox
# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile

FROM openjdk:8-jre-stretch
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

COPY --from=kaniko /kaniko /kaniko
COPY --from=busybox /bin /busybox

RUN apt-get update && apt-get install -y \
    git \
    jq \
    make \
    && rm -rf /var/lib/apt/lists/*

ENV DOCKER_CONFIG /kaniko/.docker/
ENV PATH="${PATH}:/kaniko:/busybox"
ENV SSL_CERT_DIR=/kaniko/ssl/certs

# Declare /busybox as a volume to get it automatically whitelisted
VOLUME /busybox

# The following could be used to preconfigure the image with the ECR docker credentials helper
# RUN mkdir -p ${DOCKER_CONFIG} && echo '{"credsStore": "ecr-login"}' > ${DOCKER_CONFIG}/config.json
WORKDIR /home/jenkins
ENTRYPOINT ["/kaniko/executor"]