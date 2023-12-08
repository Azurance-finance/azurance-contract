source .env
export RPC_URL=$ARBITRUM_GOERLI_RPC_URL
export EXPLORER_URL=$ARBITRUM_GOERLI_SCAN_URL
export EXPLORER_API_KEY=$ARBITRUM_GOERLI_SCAN_API_KEY

forge script script/deploy/DeployFactory.s.sol --rpc-url $RPC_URL --verifier-url $EXPLORER_URL --etherscan-api-key $EXPLORER_API_KEY --broadcast --verify