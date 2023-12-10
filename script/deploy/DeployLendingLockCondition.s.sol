// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/LendingLockCondition.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";

contract DeployLendingLockCondition is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new LendingLockCondition(
            // fuji_ccip = fuji ccip contract address
            0x1515Fa830a4025436e9578d2f43542201feff208,
            // destinationChainSelector = mumbai chain selector => https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet
            12532609583862916517,
            // receiver = mumbai ccip contract address
            0x1ebD1DD7CEFAE66661A90AF8C7bA2c18b6207E8F,
            // text => for check lending status
            "check_lending_status"
        );

        vm.stopBroadcast();
    }
}
