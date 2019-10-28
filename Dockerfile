FROM debian:stable
MAINTAINER Jens Köhler, jens.koehler@arvato.com

WORKDIR /root

RUN apt-get update && \
    apt-get -y --no-install-recommends install curl python3 python3-pip python3-setuptools \
        ca-certificates && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.6/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    pip3 install awscli && \
    apt-get purge -y curl \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean
