#!/bin/bash

# Set the hostname in /etc/hosts
HOST_IP=$(/sbin/ip route|awk '/link/ { print $9 }')
echo "Host IP is: $HOST_IP"
echo "$HOST_IP mongoc" >> /etc/hosts

# Start config server (defaults to listening on port 27019, datadir /data/configdb)
mongod --configsvr --replSet storjsdkcfg --sslPEMKeyFile /etc/mongodb.pem --sslMode requireSSL --sslAllowInvalidCertificates --sslAllowInvalidHostnames --sslAllowConnectionsWithoutCertificates &

sleep 10

# Initiate the replicaset
mongo --port 27019 --ssl --sslAllowInvalidHostnames --sslAllowInvalidCertificates --eval '
rs.initiate(
   {
      _id: "storjsdkcfg",
      configsvr: true,
      members: [
         { _id: 0, host : "mongoc:27019" }
      ]
   }
)
'

sleep infinity
