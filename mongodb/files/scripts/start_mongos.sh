#!/bin/bash

# Start mongos
mongos --configdb storjsdkcfg/mongoc:27019 --sslPEMKeyFile /etc/mongodb.pem --sslMode requireSSL --sslAllowInvalidCertificates --sslAllowInvalidHostnames --sslAllowConnectionsWithoutCertificates &

# Should replace this with something to watch for mongo to be ready to accept connections
sleep 10

# Connect to mongo and add the data node
mongo --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames --eval "sh.addShard('storjsdk/mongod:27018')" &

# Create the storj db user on the bridge database
echo "Creating storj DB user"
mongo --port 27017 --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames bridge --eval '
db.createUser(
  {
    user: "storj",
    pwd: "password",
    roles: [ { role: "readWrite", db: "bridge" } ]
  }
)
'

# Sleep forever to keep the container running
sleep infinity
