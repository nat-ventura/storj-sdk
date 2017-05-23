#!/bin/bash

# Changing these do nothing currently
STORJ_BRIDGE_USERNAME=user@storj.io
STORJ_BRIDGE_PASSWORD=password

COMPOSE_PREFIX=$(./scripts/get_compose_prefix.sh)

# Should set these to use defaults if you press enter at the prompts
echo "Please register a test user. (do not use an important password!)"
echo -n "Email: "
read STORJ_BRIDGE_USERNAME
echo -n "Password: "
read -s STORJ_BRIDGE_PASSWORD
printf "\n"

export STORJ_BRIDGE_USERNAME=$STORJ_BRIDGE_USERNAME
export STORJ_BRIDGE_PASSWORD=$STORJ_BRIDGE_PASSWORD

# Get the local bridge URL
export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)

# Check to see if the user is already logged in, if so, log them out
#spawn storj register

#expect "email"
#send "$STORJ_BRIDGE_USERNAME"
#
#expect "password"
#send "$STORJ_BRIDGE_PASSWORD"
#

./scripts/add_user.exp

echo "Activating user $USERNAME"

# You could use this to activate a user
docker exec -it ${COMPOSE_PREFIX}_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.update({_id: \"$USERNAME\"}, {\$set:{\"activated\": true}});'" > /dev/null 2>&1

storj login
