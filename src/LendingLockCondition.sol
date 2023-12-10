// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IAzuranceCondition.sol";
import "./interfaces/IAzurancePool.sol";
import "./interfaces/ICovidFunction.sol";
import "./interfaces/IETHPriceFeed.sol";
import "./interfaces/IFUJIMessenger.sol";


contract LendingLockCondition is IAzuranceCondition {
    IFUJIMessenger public fuji_ccip;
    string public text;
    uint64 public destinationChainSelector;
    address public receiver;

    constructor(address _fuji_ccip,uint64 _destinationChainSelector, address _receiver, string memory _text) {
        fuji_ccip = IFUJIMessenger(_fuji_ccip);
        destinationChainSelector = _destinationChainSelector;
        receiver = _receiver;
        text = _text;
    }

    // callCheckLendingStatus
    function callCheckLendingStatus() external {
        fuji_ccip.sendMessagePayLINK(
            destinationChainSelector,
            receiver,
            text
        );
    }

    function checkUnlockClaim(address target) external override {
        // isLendingDemo = true => lending is locked or paused
        if( fuji_ccip.isLendingDemo()){
            IAzurancePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        IAzurancePool(target).unlockTerminate();
    }
}
