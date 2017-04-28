#!/bin/bash
# Get the internal network address for the bridge-gui-ssl-proxy and
# add a host entry for it

NET_NAME=$(./scripts/get_net_name.sh)

echo "If changes need to be made to your /etc/hosts file, you may be asked for your sudo password..."
echo "Always check scripts to ensure that you know what they are doing before entering your password."

for SERVICE in bridge-gui bridge bridge-gui-ssl-proxy bridge-ssl-proxy billing billing-ssl-proxy bridge-gui-vue; do
  CONTAINER_ID=$(docker ps | grep storjsdk_${SERVICE}_1 | cut -d " " -f1)
  SERVICE_IP=$(docker inspect $CONTAINER_ID | jq -r ".[0].NetworkSettings.Networks.$NET_NAME.IPAddress")

  echo "Checking to see if the $SERVICE hosts entry exists in your hosts file"

  CHECK_RESULT=$(./scripts/etchosts.sh check ${SERVICE})
  if [[ $CHECK_RESULT == *"was not found"* ]]; then
    echo "Hosts file entry for ${SERVICE} does not exist, adding it..."
    ADD_RESULT=$(sudo ./scripts/etchosts.sh add ${SERVICE} $SERVICE_IP)
  else
    if [[ $CHECK_RESULT == "$SERVICE_IP $SERVICE" ]]; then
      echo "Your /etc/hosts entry for $SERVICE with IP $SERVICE_IP is up to date."
      echo "Done."

    else
      echo "Hosts entry for $SERVICE exists but the IP is not up to date. Setting $SERVICE to $SERVICE_IP"
      UPDATE_RESULT=$(sudo ./scripts/etchosts.sh update ${SERVICE} $SERVICE_IP)
    fi
  fi
done

echo "Done."
exit 0;
