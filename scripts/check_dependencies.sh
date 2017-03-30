#!/bin/bash

# Check if the storj cli is installed
output=$(which storj)
if [[ "$?" != 0 ]]; then
  echo "It appears that the storj cli is not installed. Please install it so that you can interact with your local network"
else
  echo "Storj CLI is installed."
fi
