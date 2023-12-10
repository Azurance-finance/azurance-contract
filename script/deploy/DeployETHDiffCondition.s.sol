// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/conditions/ETHDiffCondition.sol";

contract DeployETHDiffCondition is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Price Feeds For Avalanche FUJI Testnet
        // ETH/USD => 0x86d67c3D38D2bCeE722E601025C25a575021c6EA

        new ETHDiffCondition(0x86d67c3D38D2bCeE722E601025C25a575021c6EA);

        vm.stopBroadcast();
    }
}
