FROM cloudbees/java-build-tools:2.3.0
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

USER root

RUN apt-get update -qqy \
    && apt-get -qqy --no-install-recommends install bsdmainutils \
    && rm -rf /var/lib/apt/lists/*

USER jenkins