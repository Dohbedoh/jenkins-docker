FROM docker:18.09.0-dind
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

# See https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile
ARG JRE_VERSION=8.212.04-r0
ARG AZURE_CLI_VERSION=2.0.67

# Prepare image to be used as Jenkins Agent
RUN apk --update --no-cache add \
  openjdk8-jre=${JRE_VERSION} \
  curl \
  git \
  jq \
  make \
  openssh-client \
  tar \
  bash \
  nss
  
# Install Azure CLI https://github.com/Azure/azure-cli/blob/master/Dockerfile

#RUN apk --update add jq python py-pip && \
#    apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make linux-headers && \
RUN apk --update add python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apk add --virtual=build gcc python3-dev musl-dev libffi-dev openssl-dev make linux-headers && \
    pip3 --no-cache-dir install --upgrade pip setuptools && \
    pip3 --no-cache-dir install azure-cli==${AZURE_CLI_VERSION} && \
    pip3 --no-cache-dir install --force-reinstall --upgrade azure-nspkg azure-mgmt-nspkg && \
    pip3 --no-cache-dir install --force-reinstall urllib3==1.24.2 && \
    apk -v --purge del build && \
    rm /var/cache/apk/*
#ENV PATH="/root/.local/bin:${PATH}"

COPY dind-agent-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dind-agent-entrypoint.sh"]