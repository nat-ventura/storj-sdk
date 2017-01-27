#!/usr/bin/env bash

# Not sure if we will use this or not... simply an experiment

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

# Add it to config
sed "s/{{ IP_ADDRESS }}/$IP/g" /root/.storjshare/config.template.json > /root/config.json

echo "$@"

$@

echo "Running tail"

tail -f /root/share.log
