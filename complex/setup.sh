#!/usr/bin/env bash

for dir in /usr/src/vendor/* ; do
  if [[ -d $dir ]]; then
    echo "Manually linking $dir"
    dir_name=$(basename $dir)
    rm -rf /usr/src/app/node_modules/$dir_name
    cp -rp $dir /usr/src/app/node_modules/$dir_name
  fi

  echo "Rebuilding linked modules"
  npm rebuild
done

# Fetch the IP Address of the container
IP=$(ip addr show dev eth0 | grep 'inet ' | sed 's/\// /g' | awk '{ print $2 }')

echo "$IP"

# Add it to config
sed "s/{{ IP_ADDRESS }}/$IP/g" /root/config.template.json > /root/config.json

cat /root/config.json

exec $@
