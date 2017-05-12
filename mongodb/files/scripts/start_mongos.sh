#!/bin/bash

# Start mongos
mongos --configdb storjsdkcfg/mongoc:27019 &

sleep 10

mongo --eval "sh.addShard('storjsdk/mongod:27018')" &

sleep infinity
