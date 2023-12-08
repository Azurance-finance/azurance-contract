// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/interfaces/IAzurancePool.sol";
import "../test/contracts/TestERC20.sol";

contract BuyAzurance is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IAzurancePool pool = IAzurancePool(0x60edA798a0503d81CCB2ACA7b2A098e1892e759d);

        TestERC20 token = TestERC20(0x60edA798a0503d81CCB2ACA7b2A098e1892e759d);

        uint256 amount = 100 * 10 ** token.decimals();

        token.mint(address(this), amount);
        token.approve(address(pool), amount);

        pool.buyInsurance(amount);

        vm.stopBroadcast();
    }
}
