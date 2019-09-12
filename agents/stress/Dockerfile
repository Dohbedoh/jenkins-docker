FROM debian:jessie as builder

RUN apt-get update && apt-get install -yq make gcc xz-utils

WORKDIR /code

ADD https://kernel.ubuntu.com/~cking/tarballs/stress-ng/stress-ng-0.09.60.tar.xz .
RUN tar xvf stress-ng-0.09.60.tar.xz
WORKDIR /code/stress-ng-0.09.60
RUN STATIC=1 make

FROM jenkins/jnlp-slave:alpine

USER root
COPY --from=builder /code/stress-ng-0.09.60/stress-ng /usr/bin/