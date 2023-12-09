// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/TestERC20.sol";
import "../../src/SimpleCondition.sol";
import "../../src/AzurancePool.sol";

contract DeploySimpleCondition is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SimpleCondition condition = new SimpleCondition();

        vm.stopBroadcast();
    }

}
