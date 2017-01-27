#!/usr/bin/env bash

DIRECTORY="/root/.storjshare"

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

for i in {0..10000}; do
  DIR="$DIRECTORY/farmer_$i"
  if [ ! -d "$DIR" ]; then
    echo "Creating ${DIR}..."
    mkdir -p "$DIR"
  fi
  FILE="$DIR/.claim"
  echo "Checking if $DIR is claimed..."
  if lockfile -r 0 "$DIR/.claim"; then
    echo "Claimed $DIR!"
    break
  fi
  echo "$DIR claimed, trying next..."
done

trap "{ echo 'Cleaning up $FILE'; rm -rf $FILE; }" EXIT

# Add it to config
cat /root/.storjshare/config.template.json | sed "s/{{ IP_ADDRESS }}/$IP/g" | sed "s~{{ STORAGE_PATH }}~$DIR~g" > /root/config.json

/bin/bash -c "$@"
