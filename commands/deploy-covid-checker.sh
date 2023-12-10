source .env
# TODO : Change to Chain your want to deploy
export RPC_URL=$MUMBAI_RPC_URL
export EXPLORER_URL=$MUMBAI_SCAN_URL
export EXPLORER_API_KEY=$MUMBAI_SCAN_API_KEY

forge script script/deploy/DeployCovidCondition.s.sol --rpc-url $RPC_URL --verifier-url $EXPLORER_URL --etherscan-api-key $EXPLORER_API_KEY --broadcast --verify