#!/usr/bin/env bash

echo "Installing linked modules"

cd /usr/src/app

for dir in /usr/src/vendor/* ; do
  if [[ -d $dir ]]; then
    echo "Manually linking $dir"
    dir_name=$(basename $dir)
    rm -rf /usr/src/app/node_modules/$dir_name
    cp -rp $dir /usr/src/app/node_modules/$dir_name
  fi

  echo "Rebuilding linked modules"
  npm rebuild
done

# BASE_PATH is where we will store all config files dynamically generated at
# runtime
BASE_PATH=${BASE_PATH:=/share}

if [ ! -d "$BASE_PATH" ]; then
  echo "Creating data dir: $BASE_PATH"
  mkdir -p "${BASE_PATH}"
fi

SHARE_CONFIG_DIR="/etc/storj"

# Farmers claim data directories in the order they startup, allowing farmers to
# persist data to disk _and_ scale at the same time. The logic here is that
# the farmer attempts to create a lockfile to claim a directory, if there aren't
# any available directories it attempts to create a new one and claim it
for i in {1..10000}; do
  INSTANCE="farmer_${i}"
  CURRENT_DIR="${BASE_PATH}/instances/${INSTANCE}"

  # If we are trying to claim a directory that doesnt exist, create it
  if [ ! -d "${CURRENT_DIR}" ]; then
    echo "Creating ${CURRENT_DIR}..."
    mkdir -p "${CURRENT_DIR}"
  fi

  CLAIM_FILE="${CURRENT_DIR}/.claim"

  echo "Checking if ${CURRENT_DIR} is claimed..."
  if lockfile -r 0 "${CLAIM_FILE}"; then
    echo "Claimed $DIR!"
    break
  fi

  echo "${CURRENT_DIR} claimed, trying next..."
done

# Make sure that we don't abandon a .claimfile when shutting down preventing a
# future farmer from claiming the data
trap "{ echo 'Cleaning up ${CLAIM_FILE}'; rm -rf ${CLAIM_FILE}; }" EXIT

# Store all of the farmer's shards and the farmer's keyfile in the storage path
STORAGE_PATH="${CURRENT_DIR}/shards"
#  Working around a bug *** THIS IS TEMPOARY ***
# STORAGE_PATH="/tmp/shards"

KEY_PATH="${CURRENT_DIR}/KEY_FILE"

# Make sure STORAGE_PATH exists, otherwise write a helpful message to the log
# and create it
if [ ! -d "${STORAGE_PATH}" ]; then
  echo "Creating ${STORAGE_PATH}..."
  mkdir -p "${STORAGE_PATH}"
fi

if [ ! -d "${SHARE_CONFIG_DIR}" ]; then
  echo "Creating ${SHARE_CONFIG_DIR}..."
  mkdir -p "${SHARE_CONFIG_DIR}"
fi

# Fetch the IP Address of the container that was assigned when it started up
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

echo "KEY_PATH is $KEY_PATH"

# Try to load KEY from file for this farmer
if [ -f "${KEY_PATH}" ]; then
  echo "Found PRIVATE_KEY file, importing key"
  PRIVATE_KEY="$(cat "${KEY_PATH}")"
else
  # Generate a key using storj-lib
  echo "No PRIVATE_KEY file found, generating a new one"
  PRIVATE_KEY=$(node -e "
    var storj = require('storj-lib');
    console.log('%s', storj.KeyPair().getPrivateKey());
  ")
  echo "${PRIVATE_KEY}" > "${KEY_PATH}"
fi

echo "IP: ${IP}"
echo "Key file path: ${KEY_PATH}"
echo "Key: ${PRIVATE_KEY}"
echo "Storage: ${STORAGE_PATH}"
echo "Config Link Path: ${SHARE_CONFIG_LINK_PATH}"

# Check if we have a config file and update
cat "${BASE_PATH}/templates/config.template.json" | \
  sed "s/{{ IP }}/${IP}/g" | \
  sed "s~{{ STORAGE_PATH }}~${STORAGE_PATH}~g" | \
  sed "s~{{ PRIVATE_KEY }}~${PRIVATE_KEY}~g" \
  > "${BASE_PATH}/config.json"

ls ${BASE_PATH}
cat "${BASE_PATH}/templates/config.template.json"

echo "Compiled config..."
cat "${BASE_PATH}/config.json"

echo "Checking to see if link to config file exists at $SHARE_CONFIG_DIR/share.json"
if [ ! -f $SHARE_CONFIG_DIR/share.json ]; then
  echo "Config file link does not exist. Creating."
  ln -s ${BASE_PATH}/config.json ${SHARE_CONFIG_DIR}/share.json
else
  echo "Config file link exists."
fi

/bin/bash -c -- "$@"

DAEMON_LOGS="/var/log/storj.daemon.log"
FARMER_LOGS="/var/log/storj.farmer.log"

#COUNTER=0
#while [ ! -f "${DAEMON_LOGS}" ]; do
#  sleep 1;
#  ((COUNTER+=1))
#
#  if [[ "${COUNTER}" -eq 10 ]]; then
#    echo "Didn't find log file: ${DAEMON_LOGS}"
#    exit 1;
#  fi
#done

COUNTER=0
while [ ! -f "${FARMER_LOGS}" ]; do
  sleep 1;
  ((COUNTER+=1))

  if [[ "${COUNTER}" -eq 10 ]]; then
    echo "Didn't find log file: ${FARMER_LOGS}"
    exit 1;
  fi
done

tail -f "${DAEMON_LOGS}" "${FARMER_LOGS}"
#tail -f "${FARMER_LOGS}"
#tail -f "${DAEMON_LOGS}"
