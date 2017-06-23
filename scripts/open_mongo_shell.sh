#!/bin/bash

mongo --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames --authenticationDatabase bridge -u storj -p password mongodb://$(./scripts/get_local_db.sh)/bridge
