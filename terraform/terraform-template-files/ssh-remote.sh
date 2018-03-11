#!/bin/bash

# concatenate ssh config defs to ~/.ssh/config
cat ~/*.ssh.config | tee ~/.ssh/config

# append hosts to /etc/hosts file
cat ~/hosts_* | sudo tee -a /etc/hosts

# generate a local public/private ssh keypair if one does not exist
if [[ ! -f /home/${user}/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -b 4096 -f /home/${user}/.ssh/id_rsa -N '' -C '' 
    cat /home/${user}/.ssh/id_rsa.pub | tee -a /home/${user}/.ssh/authorized_keys
fi
