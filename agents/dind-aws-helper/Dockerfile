# Stage 0: Get credential helpers
FROM golang:1.10
RUN go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
RUN make -C /go/src/github.com/awslabs/amazon-ecr-credential-helper linux-amd64

FROM docker:18.09.0-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>
COPY --from=0 /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/linux-amd64/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
RUN mkdir -p ~/.docker && echo "{\"credsStore\": \"ecr-login\"}}" > ~/.docker/config.json

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.212.04-r0
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

COPY dind-agent-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dind-agent-entrypoint.sh"]