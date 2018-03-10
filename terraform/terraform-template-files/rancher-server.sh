#!/bin/bash

RANCHER_FLAG=$(docker ps | grep "rancher/server")

if [[ $RANCHER_FLAG != "" ]]; then
    echo "Rancher/server discovered running; doing nothing"
    exit
fi

sudo docker run -d \
    --restart=unless-stopped \
    -p 8080:8080 \
    --name ${rancher-name} \
    rancher/server:stable \
    --db-host ${db-host}\
    --db-port ${db-port}\
    --db-name ${db-name}\
    --db-user ${db-user}\
    --db-pass ${db-pass}\
    --db-strict-enforcing
