#!/bin/bash
# Find the local bridge

DB_PORT=27017
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DB_CONTAINER_ID=$(docker ps | grep mongo | cut -d " " -f1)
NET_NAME=$(./scripts/get_net_name.sh)
DB_IP=$(docker inspect $DB_CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")
DB_URL=http://$DB_IP:$DB_PORT
echo $DB_URL
