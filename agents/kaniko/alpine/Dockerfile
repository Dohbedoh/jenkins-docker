# https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile

# Stage 0: Build the executor binary and get credential helpers
#FROM golang:1.10 as golang
#WORKDIR /go/src/github.com/GoogleContainerTools/kaniko
## Get Amazon ECR credential helper
#RUN go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
#RUN make -C /go/src/github.com/awslabs/amazon-ecr-credential-helper linux-amd64 

FROM alpine:3.10 as alpine
ARG JRE_VERSION=8.212.04-r0
# Prepare image to be used as Jenkins Agent
# TODO Remove NSS when fix for https://github.com/docker-library/openjdk/issues/289 is released
RUN apk --update --no-cache add \
  openjdk8-jre=$JRE_VERSION \
  curl \
  bash \
  git \
  jq \
  make \
  openssh-client \
  nss

#FROM scratch
#MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>
#COPY --from=golang /go/src/github.com/GoogleContainerTools/kaniko/out/executor /kaniko/executor
#COPY --from=golang /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/linux-amd64/docker-credential-ecr-login /kaniko/docker-credential-ecr-login
#
#COPY --from=alpine / /alpine/
#COPY --from=alpine /bin/bash /bin/bash
#COPY --from=alpine /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
#
## Declare /alpine as a volume to get it automatically whitelisted
#VOLUME /alpine
#COPY files/ca-certificates.crt /kaniko/ssl/certs/
#COPY --from=golang /root/.docker/config.json /kaniko/.docker/config.json
#ENV HOME /root
#ENV USER /root
#ENV LD_LIBRARY_PATH /alpine/lib:/alpine/usr/lib/
#ENV PATH /usr/local/bin:/kaniko:/alpine/usr/bin:/alpine/usr/sbin:/alpine/bin/:/alpine/sbin
#ENV SSL_CERT_DIR=/kaniko/ssl/certs
#ENV DOCKER_CONFIG /kaniko/.docker/
#ENTRYPOINT ["/kaniko/executor"]

FROM gcr.io/kaniko-project/executor:latest
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

COPY --from=alpine / /alpine/
COPY --from=alpine /bin/bash /bin/bash
COPY --from=alpine /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

# Declare /alpine as a volume to get it automatically whitelisted
VOLUME /alpine

ENV LD_LIBRARY_PATH "/alpine/lib:/alpine/usr/lib/"
ENV PATH="/usr/local/bin:/kaniko:/alpine/usr/bin:/alpine/usr/sbin:/alpine/bin/:/alpine/sbin"

ENTRYPOINT ["/kaniko/executor"]