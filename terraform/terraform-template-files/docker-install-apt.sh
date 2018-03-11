#!/bin/bash

docker ps

if [[ $? -eq 0 ]]; then
    echo "Docker up and running; doing nothing"
    exit
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get -y update
#sudo apt-get -y upgrade  THIS WAS CAUSING PROBLEMS
export DOCKER_APT=$(apt-cache madison docker-ce | grep --color=none ${docker_version} | cut -d " " -f 4)
sudo apt-get -y install docker-ce=$DOCKER_APT
sudo usermod -aG docker ${user}
