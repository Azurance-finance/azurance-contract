source .env
# TODO : Change to Chain your want to deploy
export RPC_URL=$MUMBAI_RPC_URL
export SCAN_URL=$MUMBAI_SCAN_URL
export SCAN_API_KEY=$MUMBAI_SCAN_API_KEY

forge script script/deploy/DeployMumbaiMessenger.s.sol --rpc-url $RPC_URL --verifier-url $SCAN_URL --etherscan-api-key $SCAN_API_KEY --broadcast --verify
