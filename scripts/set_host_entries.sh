#!/bin/bash
# Get the internal network address for the bridge-gui-ssl-proxy and
# add a host entry for it

NET_NAME=$(./scripts/get_net_name.sh)

for SERVICE in bridge-gui bridge; do
  SSL_PROXY_CONTAINER_ID=$(docker ps | grep ${SERVICE}-ssl-proxy | cut -d " " -f1)
  SSL_PROXY_IP=$(docker inspect $SSL_PROXY_CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")

  echo "Checking to see if the $SERVICE hosts entry exists in your hosts file"
  CHECK_RESULT=$(./scripts/etchosts.sh check ${SERVICE}-ssl-proxy)
  if [[ $CHECK_RESULT == *"was not found"* ]]; then
    echo "Hosts file entry for $SERVICE does not exist, adding it..."
    echo "The next command will be run with sudo as root is needed to update your /etc/hosts file"
    ADD_RESULT=$(sudo ./scripts/etchosts.sh add ${SERVICE}-ssl-proxy $SSL_PROXY_IP)
  else
    if [[ $CHECK_RESULT == "$SSL_PROXY_IP $SERVICE" ]]; then
      echo "Your /etc/hosts entry for $SERVICE with IP $SSL_PROXY_IP is up to date."
      echo "Done."

    else
      echo "Hosts entry for $SERVICE exists but the IP is not up to date. Setting $SERVICE to $SSL_PROXY_IP"
      echo "The next command will be run with sudo as root is needed to update your /etc/hosts file"
      UPDATE_RESULT=$(sudo ./scripts/etchosts.sh update ${SERVICE}-ssl-proxy $SSL_PROXY_IP)
    fi
  fi
done

echo "Done."
exit 0;
