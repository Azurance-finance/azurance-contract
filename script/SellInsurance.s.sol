// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/interfaces/IAzurancePool.sol";
import "../test/contracts/TestERC20.sol";

contract SellInsurance is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IAzurancePool pool = IAzurancePool(0x2a26e41f3f332d91bdf405902550116cbc84fba0);

        TestERC20 token = TestERC20(0x02c23a6ecfac21b1409fd78684a614dd78f2b6b7);

        uint256 amount = 1000 * 10 ** token.decimals();

        token.mint(address(this), amount);
        token.approve(address(pool), amount);

        pool.sellInsurance(amount);

        vm.stopBroadcast();
    }
}
