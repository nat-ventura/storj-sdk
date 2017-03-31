#!/bin/bash

# Get the local bridge URL
export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)

BASE_DIR=$(pwd)
FULL_PATH=${BASE_DIR//-}
PROJECT_NAME=${FULL_PATH##*/}

echo "net name: $NET_NAME"

echo "Found Storj bridge at $STORJ_BRIDGE"

# Make sure we can connect to the bridge before moving along
output=$(./scripts/wait_for_service.sh $STORJ_BRIDGE)

if [ $? -ne 0 ]; then
  echo "Failed to connect to local bridge. Ensure that you have VPN set up and that it is connected."
  exit 1;
fi

# Changing these do nothing currently
export STORJ_BRIDGE_USERNAME='test@storj.io'
export STORJ_BRIDGE_PASSWORD='password'

./scripts/add_user.exp

# Need to check to make sure user was actually added

echo -e "\n\n"
echo "Activating user $STORJ_BRIDGE_USERNAME"

# You could use this to activate a user
output=$(docker exec -it ${PROJECT_NAME}_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.update({_id: \"$STORJ_BRIDGE_USERNAME\"}, {\$set:{\"activated\": true}});'")

echo -e "User activated.\n"
