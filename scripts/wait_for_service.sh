#!/bin/bash

SERVICE=$1

# SHould make this fail eventually
until $(curl --output /dev/null --connect-timeout 2 --silent --head --fail $SERVICE); do
    printf '.'
    sleep 1
done

exit 0
