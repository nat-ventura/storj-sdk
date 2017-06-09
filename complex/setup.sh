#!/usr/bin/env bash

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

echo "IP is ${HOSTNAME}"

regex="^.*\.([0-9]*)$"
if [[ $IP =~ $regex ]]; then
  echo "Host regex match!"
  HOST_NUMBER=${BASH_REMATCH[1]}
  echo "Host number is ${HOST_NUMBER}"
  NETWORK_INDEX=$((HOST_NUMBER+1))
  echo "Network index is ${NETWORK_INDEX}"
else
  # Should simulate this with ${RANDOM} to test contact collections on share side
  echo "Could not get network index from host, using default of 1"
  NETWORK_INDEX=1
fi

echo "Network index is ${NETWORK_INDEX}"

# Add it to config
cat "/etc/storj/complex.config.template.json" | \
  sed "s/{{ NETWORK_INDEX }}/${NETWORK_INDEX}/g" | \
  sed "s/{{ IP_ADDRESS }}/$IP/g" \
  > /etc/storj/complex.config.json

cat /etc/storj/complex.config.json

exec $@
