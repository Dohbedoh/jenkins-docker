FROM jenkins/slave:alpine
MAINTAINER Allan Burdajewicz <allan.burdajewicz@gmail.com>

USER root
RUN apk --update --no-cache add git-lfs
USER jenkins
RUN git lfs install
# RUN git lfs install --skip-smudge
