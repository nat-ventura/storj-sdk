#!/bin/bash

# run `$ ./stresstest.sh <id>`, where <id> is a number or string used to distinguish
# files created by this script from files created by concurrent instances of the script
# `storj` command should be installed (`$ sudo make install` from storj-sdk/cli/libstorj)
# $STORJ_BUCKET should be set as well as any environment variables required for
# connection and authentication to local bridge

#UV_THREADPOOL_SIZE=4 # limit number of concurrent threads
mkdir -p temp
for i in `seq 1 3000`; do
  mkfile -n 20m temp/test.$1.$i.asdf;
  #cat /dev/random | head -c 20m  > temp/test.$1.$i.asdf;
  storj upload-file $STORJ_BUCKET ./temp/test.$1.$i.asdf;
done
