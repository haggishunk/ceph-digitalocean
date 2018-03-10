#!/bin/bash

NGINX_FLAG=$(docker ps | grep "nginx")

if [[ $NGINX_FLAG != "" ]]; then
    echo "Nginx discovered running; doing nothing"
    exit
fi

sudo docker run -d \
    -p 80:80 -p 443:443 \
    --name nginx-rancher \
    --link ${rancher-name} \
    -v $HOME/certs:/etc/nginx/certs:ro \
    -v $HOME/nginx/conf.d:/etc/nginx/conf.d \
    nginx
