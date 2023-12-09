// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/DAI.sol";
import "../../test/contracts/WETH.sol";
import "../../test/contracts/USDT.sol";

contract DeployTokens is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DAI dai = new DAI();
        WETH weth = new WETH();
        USDT usdt = new USDT();

        vm.stopBroadcast();
    }
}
