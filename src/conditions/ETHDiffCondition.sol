// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/IAzuranceCondition.sol";
import "../interfaces/IAzurancePool.sol";
import "../interfaces/ICovidFunction.sol";
import "../interfaces/IETHPriceFeed.sol";


contract ETHDiffCondition is IAzuranceCondition {
    IETHPriceFeed public dataFeed;

    constructor(address _dataFeed) {
        dataFeed = IETHPriceFeed(_dataFeed);
    }

    function checkUnlockClaim(address target) external override {
        // eth diff -50%
        if( dataFeed.pricediff() < -50){
            IAzurancePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        IAzurancePool(target).unlockTerminate();
    }
}
