forge verify-contract 0xb0b001478b069FaC8b849c237f0c0fba790aA630 ./src/conditions/CovidCondition.sol:CovidCondition \
--verifier-url 'https://api.routescan.io/v2/network/testnet/evm/43113/etherscan' \
--etherscan-api-key "verifyContract" \
--num-of-optimizations 200 \
--compiler-version 0.8.20 \
--constructor-args $(cast abi-encode "constructor(address _covidFunctionAddress)" 0xCe8Adb430ead472D0D24d3FF1F8c2D6e3cCa4FEe)