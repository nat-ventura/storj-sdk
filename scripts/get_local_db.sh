#!/bin/bash
# Find the local bridge

DB_PORT=27017
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DB_CONTAINER_ID=$(docker ps | grep mongos | cut -d " " -f1)
NET_NAME=$(./scripts/get_net_name.sh)
DB_IP=$(docker inspect $DB_CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")

# Need to add user, pass, SSL, allowInvalidHostnames, and sslAllowInvalidCertificates to the connection URI
DB_URL=mongodb://$DB_IP:$DB_PORT
echo $DB_URL
