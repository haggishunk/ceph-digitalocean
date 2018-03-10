#!/bin/bash
sudo apt-get install apt-transport-https
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
echo deb https://download.ceph.com/debian/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
# future improvment to replace above command
# sudo add-apt-repository \
#     "deb [arch=amd64] https://download.ceph.com/debian \
#     $(lsb_release -cs) \
#     main"
sudo apt-get -y update
sudo apt-get -y install ceph-deploy
sudo apt-get -y install jq
