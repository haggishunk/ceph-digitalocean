#!/bin/bash

# initialize kubernetes cluster and dump logs to file
# then extract join token
sudo kubeadm init --pod-network-cidr ${network_cidr} > kubeadm-init.log
grep --color=none 'kubeadm join' kubeadm-init.log | tee kube-join

# set up permissions for cluster control
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# apply pod networking, remove master taint
sudo kubectl apply -f kube-flannel.yml
sudo kubectl taint nodes --all node-role.kubernetes.io/master-

# generate a ca cert hash (no longer needed but remaining vestigial)
openssl x509 -pubkey \
    -in /etc/kubernetes/pki/ca.crt | openssl rsa \
    -pubin -outform der 2>/dev/null | openssl dgst \
    -sha256 -hex | sed 's/^.* //' | \
    tee ca-cert-hash

# parse certificates and key for api access
grep client-cert .kube/config  | cut -d " " -f 6 | base64 -d - | tee client.pem
grep client-key  .kube/config  | cut -d " " -f 6 | base64 -d - | tee client-key.pem
grep authority   .kube/config  | cut -d " " -f 6 | base64 -d - | tee ca.pem

# enable kubectl bash completion
echo 'source <(kubectl completion bash)' | tee -a .bashrc
