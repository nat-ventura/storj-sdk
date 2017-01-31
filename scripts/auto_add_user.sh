#!/bin/bash

# Get the local bridge URL
export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)

echo "Found Storj bridge at $STORJ_BRIDGE"

# Make sure we can connect to the bridge before moving along
curl $STORJ_BRIDGE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to connect to local bridge. Ensure that you have VPN set up and that it is connected."
  exit 1;
fi

# Changing these do nothing currently
export STORJ_BRIDGE_USERNAME='test2@storj.io'
export STORJ_BRIDGE_PASSWORD='password'

./scripts/add_user.exp

echo "Activating user $STORJ_BRIDGE_USERNAME"

# You could use this to activate a user
docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.update({_id: \"$STORJ_BRIDGE_USERNAME\"}, {\$set:{\"activated\": true}});'" > /dev/null 2>&1

echo -e "User activated.\n"
echo -e "Logging in..."

./scripts/login_user.exp

echo -e "\n"
echo "  - credentials -"
echo "User: $STORJ_BRIDGE_USERNAME"
echo "Pass: $STORJ_BRIDGE_PASSWORD"
echo ""
echo "To start using storj, run the following command:"
echo "export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)"
