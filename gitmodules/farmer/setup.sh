#!/usr/bin/env bash

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

# Add it to config
sed "s/{{ IP_ADDRESS }}/$IP/g" /root/.storjshare/config.template.json > /root/.storjshare/config.json

exec $@
