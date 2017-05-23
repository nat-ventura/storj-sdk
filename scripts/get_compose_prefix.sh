#!/bin/bash

CURRENT_DIR=${PWD##*/}
COMPOSE_PREFIX=$(echo "${CURRENT_DIR//-}")

echo $COMPOSE_PREFIX
