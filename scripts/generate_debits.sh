#!/bin/bash
docker-compose run billing-importer bin/create-debits.js $@
