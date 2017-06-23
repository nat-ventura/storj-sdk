#!/bin/bash

# Set the hostname in /etc/hosts
HOST_IP=$(/sbin/ip route|awk '/link/ { print $9 }')
echo "Host IP is: $HOST_IP"
echo "$HOST_IP mongod" >> /etc/hosts

# Start mongod (defaults to listening on port 27018)
echo "Starting MongoDB..."
mongod --shardsvr --replSet storjsdk --sslPEMKeyFile /etc/mongodb.pem --sslMode requireSSL --sslAllowInvalidCertificates --sslAllowInvalidHostnames --sslAllowConnectionsWithoutCertificates &

# Should loop and check for primary until its available instead of sleeping
sleep 30

# Initiate the replicaset
echo "Initiating replicaset"
mongo --port 27018 --ssl --sslAllowInvalidHostnames --sslAllowInvalidCertificates --eval '
rs.initiate(
   {
      _id: "storjsdk",
      members: [
         { _id: 0, host : "mongod:27018" }
      ]
   }
)
'

# Create the admin db user on the admin database
echo "Creating admin DB user"
mongo --port 27018 --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames admin --eval '
db.createUser(
  {
    user: "root",
    pwd: "password",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
'

# Create the storj db user on the bridge database
#echo "Creating storj DB user"
#mongo --port 27018 --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames bridge --eval '
#db.createUser(
#  {
#    user: "storj",
#    pwd: "password",
#    roles: [ { role: "readWrite", db: "bridge" } ]
#  }
#)
#'

# Stop the currently running mongo process
#echo "Stopping mongo..."
#mongo --port 27018 --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames admin --eval '
#db.shutdownServer({ force: true })
#'

#sleep 5

#echo "Checking lockfile"
#ls /data/db | grep lock

# Need to add keyfile auth for auth between the mongos and mongod so that we can enable auth
# and use the admin user to secure the backend mongod instances

# Start mongo back up with auth enabled
#echo "Starting mongo with auth enabled"
#mongod --shardsvr --auth --replSet storjsdk --sslPEMKeyFile /etc/mongodb.pem --sslMode requireSSL --sslAllowInvalidCertificates --sslAllowInvalidHostnames --sslAllowConnectionsWithoutCertificates &

sleep infinity
