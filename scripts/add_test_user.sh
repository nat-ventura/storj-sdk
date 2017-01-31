#!/bin/bash

# Changing these do nothing currently
STORJ_BRIDGE_USERNAME=user@storj.io
STORJ_BRIDGE_PASSWORD=password

# Get the local bridge URL
STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)

# Check to see if the user is already logged in, if so, log them out
#storj register

#echo -n "To activate your user, please enter the username that you registered with followed by [ENTER]:"

read USERNAME

echo "Activating user $USERNAME"

# You could use this to activate a user
#docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.update({_id: \"$USERNAME\"}, {\$set:{\"activated\": true}});'" > /dev/null 2>&1

# Manually add a user to the database
docker exec -it storjsdk_db_1 /bin/bash -c "mongo localhost:27017/storj-sandbox --eval 'db.users.insert({ \"_id\" : \"user@storj.io\", \"hashpass\" : \"113459eb7bb31bddee85ade5230d6ad5d8b2fb52879e00a84ff6ae1067a210d3\", \"paymentProcessors\" : [ ], \"bytesDownloaded\" : { \"lastMonthBytes\" : 0, \"lastDayBytes\" : 0, \"lastHourBytes\" : 0 }, \"bytesUploaded\" : { \"lastMonthBytes\" : 0, \"lastDayBytes\" : 0, \"lastHourBytes\" : 0 }, \"isFreeTier\" : true, \"activated\" : true, \"resetter\" : null, \"deactivator\" : null, \"activator\" : \"2601a45a05dab22627933bdc4561783264b10ed8f728ee9020a78e6605504c56\", \"created\" : ISODate(\"2017-01-31T18:18:42.523Z\"), \"pendingHashPass\" : null, \"__v\" : 0 })'" > /dev/null 2>&1

storj login

storj list-buckets
