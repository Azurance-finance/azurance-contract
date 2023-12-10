// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/TestERC20.sol";
import "../../src/CovidCondition.sol";
import "../../src/AzurancePool.sol";

contract DeployCovidCondition is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // require chainlink function address
        CovidCondition condition = new CovidCondition(address(0xCe8Adb430ead472D0D24d3FF1F8c2D6e3cCa4FEe));

        vm.stopBroadcast();
    }

}
