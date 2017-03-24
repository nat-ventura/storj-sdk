#!/bin/bash
# Find the local bridge

BRIDGE_PORT=8080
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BRIDGE_CONTAINER_ID=$(docker ps | grep "bridge " | cut -d " " -f1)
NET_NAME=$(./scripts/get_net_name.sh)
BRIDGE_IP=$(docker inspect $BRIDGE_CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")
BRIDGE_URL=http://$BRIDGE_IP:$BRIDGE_PORT
echo $BRIDGE_URL
