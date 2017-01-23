#!/usr/bin/env bash

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

# From the IP address, get the last octet

# Use the last octet to add to a base port number to create a unique port

# How can we do this after the host has been launched the trigger docker to map the port afterwards?

# Add it to config
sed "s/{{ IP_ADDRESS }}/$IP/g" /root/.storjshare/config.template.json > /root/.storjshare/config.json

exec $@
