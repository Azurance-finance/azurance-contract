// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/interfaces/IAzurancePool.sol";
import "../test/contracts/TestERC20.sol";

contract BuyAzurance is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IAzurancePool pool = IAzurancePool(0x2A26e41F3F332D91BDF405902550116cBc84fbA0);
        TestERC20 token = TestERC20(0x02C23A6ecFAC21B1409FD78684a614Dd78F2B6b7);

        uint256 amount = 100 * 10 ** token.decimals();

        token.mint(address(this), amount);
        token.approve(address(pool), amount);

        pool.buyInsurance(amount);

        vm.stopBroadcast();
    }
}
