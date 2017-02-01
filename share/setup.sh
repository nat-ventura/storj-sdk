#!/usr/bin/env bash

# $BASE_PATH - Base BASE_PATH for farmer configs and data

if [ ! -d "$BASE_PATH" ]; then
  echo "Creating data dir: $BASE_PATH"
  mkdir -p "$BASE_PATH"
fi

SCRIPTS_DIR="$BASE_PATH/scripts"
TEMPLATES_DIR="$BASE_PATH/templates"
LOGS_DIR="$BASE_PATH/logs"

# Starting at 0, look for farmer directories until we find one
#   that is unlocked or run out then create a new one
for i in {1..10000}; do
  INSTANCE="farmer_$i"
  CURRENT_DIR="$BASE_PATH/instances/$INSTANCE"

  # If we're looking for a BASE_PATH that doesnt exist, create it and init its config
  if [ ! -d "$CURRENT_DIR" ]; then
    echo "Creating ${CURRENT_DIR}..."
    mkdir -p "$CURRENT_DIR"
  fi

  CLAIM_FILE="$CURRENT_DIR/.claim"

  echo "Checking if $CURRENT_DIR is claimed..."

  if lockfile -r 0 "$CURRENT_DIR/.claim"; then
    echo "Claimed $DIR!"

    SHARE_CONFIG_DIR="$CURRENT_DIR/config"
    SHARE_DATA_DIR="$CURRENT_DIR/data"
    SHARE_LOGS_DIR="$CURRENT_DIR/logs"

    if [ ! -d "$SHARE_CONFIG_DIR" ]; then
      echo "Creating ${SHARE_CONFIG_DIR}..."
      mkdir -p "$SHARE_CONFIG_DIR"
    fi

    if [ ! -d "$SHARE_DATA_DIR" ]; then
      echo "Creating ${SHARE_DATA_DIR}..."
      mkdir -p "$SHARE_DATA_DIR"
    fi

    if [ ! -d "$SHARE_LOGS_DIR" ]; then
      echo "Creating ${SHARE_LOGS_DIR}..."
      mkdir -p "$SHARE_LOGS_DIR"
    fi

    break
  fi
  echo "$CURRENT_DIR claimed, trying next..."
done

trap "{ echo 'Cleaning up $CLAIM_FILE'; rm -rf $CLAIM_FILE; }" EXIT

# Every time we start a farmer, we should check to see if we already have a config for that farmer.
# We should then in place update the IP address with an updated IP

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

# Try to load KEY from file for this farmer
KEY_FILE="KEY_FILE"
KEY_FILE_PATH="$SHARE_CONFIG_DIR/$KEY_FILE"
if [ -f $KEY_FILE_PATH ]; then
  KEY=$(cat $KEY_FILE_PATH);
else
  KEY=$(node $SCRIPTS_DIR/gen_key.js)
  echo $KEY > $KEY_FILE_PATH
fi

mkdir /etc/storj

if [ ! -f $SHARE_CONFIG_DIR/share.json ]; then
  ln -s $SHARE_CONFIG_DIR/share.json /etc/storj/share.json
fi

echo "Share config dir: $SHARE_CONFIG_DIR"
echo "Share logs dir: $SHARE_LOGS_DIR"
echo "Share data dir: $SHARE_DATA_DIR"
echo "Key file path: $KEY_FILE_PATH"
echo "Share key: $KEY"

# Check if we have a config file and update
cat $TEMPLATES_DIR/config.template.json | sed "s/{{ IP_ADDRESS }}/$IP/g" | sed "s~{{ STORAGE_PATH }}~$SHARE_DATA_DIR~g" | sed "s~{{ PRIVATE_KEY }}~$KEY~g" | sed "s~{{ LOG_FILE_PATH }}~$SHARE_LOGS_DIR/share.log~g" > $SHARE_CONFIG_DIR/share.json

/bin/bash -c "$@"

COUNTER=0
while [ ! -f $SHARE_LOGS_DIR/share.log ]; do
  sleep 1;
  (($COUNTER+=1))

  if [[ $COUNTER -eq 10 ]]; then
    echo "Unable to tail log file"
    exit 1;
  fi
done

tail -f $SHARE_LOGS_DIR/share.log
