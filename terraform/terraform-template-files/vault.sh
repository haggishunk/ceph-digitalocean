#!/bin/bash

mkdir $HOME/bin
curl -sSL 'https://releases.hashicorp.com/vault/0.9.5/vault_0.9.5_linux_amd64.zip?_ga=2.109483141.1890836254.1519520847-1630512463.1515562937' > vault.zip
sudo apt-get install unzip
unzip vault.zip
mv vault bin/
rm vault.zip
