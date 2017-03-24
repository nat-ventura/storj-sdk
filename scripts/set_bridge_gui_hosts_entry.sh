#!/bin/bash
# Get the internal network address for the bridge-gui-ssl-proxy and
# add a host entry for it

SSL_PROXY_CONTAINER_ID=$(docker ps | grep bridge | cut -d " " -f1)
NET_NAME=$(./scripts/get_net_name.sh)
SSL_PROXY_IP=$(docker inspect $SSL_PROXY_CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")

echo "Checking to see if the bridge-gui hosts entry exists in your hosts file"
CHECK_RESULT=$(./scripts/etchosts.sh check bridge-gui)
if [[ $CHECK_RESULT == *"was not found"* ]]; then
  echo "Hosts file entry for bridge-gui does not exist, adding it..."
  echo "The next command will be run with sudo as root is needed to update your /etc/hosts file"
  ADD_RESULT=$(sudo ./scripts/etchosts.sh add bridge-gui $SSL_PROXY_IP)
else
  if [[ $CHECK_RESULT == "$SSL_PROXY_IP bridge-gui" ]]; then
    echo "Your /etc/hosts entry for bridge-gui with IP $SSL_PROXY_IP is up to date."
    echo "Done."
    exit 0;
  fi

  echo "Hosts entry for bridge-gui exists but the IP is not up to date. Setting bridge-gui to $SSL_PROXY_IP"
  echo "The next command will be run with sudo as root is needed to update your /etc/hosts file"
  UPDATE_RESULT=$(sudo ./scripts/etchosts.sh update bridge-gui $SSL_PROXY_IP)

  echo "Done."
  exit 0;
fi

