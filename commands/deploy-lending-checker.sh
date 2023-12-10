source .env
# TODO : Change to Chain your want to deploy
export RPC_URL=$FUJI_RPC_URL
export EXPLORER_URL=$FUJI_SCAN_URL
export EXPLORER_API_KEY=$FUJI_SCAN_API_KEY

forge script script/deploy/DeployLendingLockCondition.s.sol --rpc-url $RPC_URL --verifier-url $EXPLORER_URL --etherscan-api-key $EXPLORER_API_KEY --broadcast --verify