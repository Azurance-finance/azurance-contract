// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/dataProviders/FUJIMessenger.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract DeployFujiMessenger is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // rounter ccip on fuji => 0xF694E193200268f9a4868e4Aa017A0118C9a8177
        // link token on fuji => 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846

        FUJIMessenger messenger = new FUJIMessenger(
            0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
        );

        // onwer address tranfer link to messenger Contract
        IERC20Metadata link = IERC20Metadata(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
        // fill 2 link token to messenger contract for link fee
        link.transfer(address(messenger), 1 * 10 ** link.decimals());

        vm.stopBroadcast();
    }
}
