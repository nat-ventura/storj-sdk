#!/bin/bash

# Changing these do nothing currently
STORJ_BRIDGE_USERNAME=billing@storj.io
STORJ_BRIDGE_PASSWORD=password

# Get the local bridge URL
STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)

# Check to see if the user is already logged in, if so, log them out
#storj register

#echo -n "To activate your user, please enter the username that you registered with followed by [ENTER]:"

#read USERNAME

#echo "Activating user $USERNAME"

# You could use this to activate a user
#docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.update({_id: \"$USERNAME\"}, {\$set:{\"activated\": true}});'" > /dev/null 2>&1

# Manually add a user to the database
docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.insert({ \"_id\" : \"billing@storj.io\", \"paymentProcessors\" : [ ], \"bytesDownloaded\" : { \"lastMonthBytes\" : 0, \"lastDayBytes\" : 0, \"lastHourBytes\" : 0 }, \"bytesUploaded\" : { \"lastMonthBytes\" : 0, \"lastDayBytes\" : 0, \"lastHourBytes\" : 0 }, \"isFreeTier\" : true, \"activated\" : true, \"resetter\" : null, \"deactivator\" : null, \"activator\" : null, \"created\" : ISODate(\"2017-01-31T18:18:42.523Z\"), \"pendingHashPass\" : null, \"__v\" : 0 })'" > /dev/null 2>&1
docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.publickeys.insert({ \"_id\" : \"02439658e54579d120b0fd24d323e413d028704f845b8f7ab5b11e91d6cd5dbb00\", \"user\" : \"billing@storj.io\", \"label\" : \"\"})'" > /dev/null 2>&1

#storj login

#storj list-buckets
