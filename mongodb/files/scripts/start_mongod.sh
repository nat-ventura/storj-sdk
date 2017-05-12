#!/bin/bash

# Set the hostname in /etc/hosts
HOST_IP=$(/sbin/ip route|awk '/link/ { print $9 }')
echo "Host IP is: $HOST_IP"
echo "$HOST_IP mongod" >> /etc/hosts

# Start mongod (defaults to listening on port 27018)
mongod --shardsvr --replSet storjsdk &

sleep 10

# Initiate the replicaset
mongo --port 27018 --eval '
rs.initiate(
   {
      _id: "storjsdk",
      version: 1,
      members: [
         { _id: 0, host : "mongod:27018" }
      ]
   }
)
'

sleep infinity
