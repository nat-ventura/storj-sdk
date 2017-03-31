#!/bin/bash

# Check if the storj cli is installed
output=$(which storj)
if [[ "$?" != 0 ]]; then
  echo "It appears that the storj cli is not installed. Please install it so that you can interact with your local network"
  exit 1
fi

output=$(which jq)
if [[ "$?" != 0 ]]; then
  echo "It appears that jq is not installed. Please install it so that the sdk script can manipulate json"
  exit 1
fi

output=$(which expect)
if [[ "$?" != 0 ]]; then
  echo "It appears that expect is not installed. Please install it so that the sdk script can handle user creation and login for the bridge"
  exit 1
fi

echo "Ok."
