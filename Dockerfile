FROM debian:stable
MAINTAINER Jens Köhler, jens.koehler@arvato.com

WORKDIR /root

RUN apt-get update && \
    apt-get -y --no-install-recommends install curl python3 python3-pip python3-setuptools ca-certificates gnupg2 apt-transport-https && \
    pip3 install awscli && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubelet kubeadm kubectl && \
    apt-get autoremove -y && \
    apt-get clean
