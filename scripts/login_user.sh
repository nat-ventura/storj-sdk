# Check output here to make sure the user was activated or at least already activated

echo -e "User activated.\n"
echo -e "Logging in..."

./scripts/login_user.exp

echo -e "\n"
echo "  - credentials -"
echo "User: $STORJ_BRIDGE_USERNAME"
echo "Pass: $STORJ_BRIDGE_PASSWORD"
echo ""
echo "To start using storj, run the following command:"
echo "export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)"
echo ""
echo "or"
echo ""
echo ". scripts/setbr"
