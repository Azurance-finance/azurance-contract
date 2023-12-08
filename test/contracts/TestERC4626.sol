// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract TestERC4626 is ERC4626 {
    constructor(address asset_) ERC4626(IERC20(asset_)) ERC20("TestYieldToken", "TYT") {}
}
