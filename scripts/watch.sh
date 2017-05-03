#!/bin/bash

# This script and the nodemon_watcher.js should live in their own docker container which has access to
# execute docker-compose commands so that it can manage rebuilding from within a container. The container
# would start and watch all apps that are desired and it should be configurable. By default it would watch
# all services.

SERVICE_TO_WATCH=$1
SERVICE_ROOT_DIR=$2
SERVICE_WATCHER_PATH=./scripts/watcher.js

nodemon $SERVICE_WATCHER_PATH $SERVICE_TO_WATCH --watch ./$SERVICE_ROOT_DIR/$SERVICE_TO_WATCH/ --watch ./$SERVICE_ROOT_DIR/$SERVICE_TO_WATCH/Dockerfile
