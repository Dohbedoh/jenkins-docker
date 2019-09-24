FROM jenkins/slave:alpine
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

USER root
RUN apk add --update --no-cache \
    curl \
    make \
    bash \
    git \
    jq \
    openssh-client

ARG MAVEN_VERSION=3.5.2
RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

USER jenkins