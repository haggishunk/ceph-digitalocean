#!/bin/bash

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | \
    sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get -y update
sudo apt-get -y install \
    kubeadm=${kube_version}-00 \
    kubelet=${kube_version}-00 \
    kubectl=${kube_version}-00
