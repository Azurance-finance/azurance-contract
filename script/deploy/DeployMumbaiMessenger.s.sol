// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import "../../src/MUMBAIMessenger.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";

contract DeployFujiMessenger is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // rounter ccip on mumbai => 0x1035cabc275068e0f4b745a29cedf38e13af41b1
        // link token on mumbai => 0x326C977E6efc84E512bB9C30f76E30c160eD06FB

        MUMBAIMessenger messenger = new MUMBAIMessenger(
            0x1035CabC275068e0F4b745A29CEDf38E13aF41b1,
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            14767482510784806043
        );

        // onwer address tranfer link to messenger Contract
        IERC20 link = IERC20(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        // fill 2 link token to messenger contract for link fee
        link.transfer(address(messenger), 1 * 10 ** link.decimals());

        vm.stopBroadcast();
    }
}
