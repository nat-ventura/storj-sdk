#!/bin/bash

#BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR=$(pwd)
NET_NAME=${BASE_DIR//-}
echo "${NET_NAME##*/}_default"
