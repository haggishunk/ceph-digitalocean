#!/bin/bash

docker ps

if [[ $? -eq 0 ]]; then
    echo "Docker up and running; doing nothing"
    exit
fi

# sudo yum update -y
curl -sSL https://releases.rancher.com/install-docker/17.03.sh | sudo sh
echo "exclude=docker-ce container-selinux" | sudo tee -a /etc/yum.conf
sudo mv $HOME/daemon.json /etc/docker/daemon.json || echo '********You will have to move daemon.json to /etc/docker and restart docker********' > nb
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker ${user}
sudo yum install -y ntp
sudo systemctl enable ntpd && sudo systemctl start ntpd
