source .env
export RPC_URL=$GOERLI_RPC_URL
export EXPLORER_URL=$GOERLI_SCAN_URL
export EXPLORER_API_KEY=$GOERLI_SCAN_API_KEY

# forge script script/deploy/DeployAll.s.sol --rpc-url $RPC_URL --verifier-url $EXPLORER_URL --etherscan-api-key $EXPLORER_API_KEY --broadcast --verify