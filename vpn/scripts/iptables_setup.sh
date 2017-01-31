#!/bin/sh

# Find the network that we want to open up via ENV variable ($DOCKER_NETWORK) (Is there a better way to find this?)
TWO_OCTETS=$(iptables-save | grep '\-A DOCKER -d' | sed -n 1p | cut -d " " -f 4 | cut -d "." -f1-2)
INTERFACE=$(iptables-save | grep '\-A DOCKER -d' | sed -n 1p | cut -d " " -f 7)
IP_RANGE="$TWO_OCTETS.0.0/24"

# Get the interface name from local ifconfig matching that network

# Use that name to open the network for port 9000
iptables -A DOCKER -d $IP_RANGE ! -i $INTERFACE -o $INTERFACE -p tcp -m tcp --dport 9000 -j ACCEPT
