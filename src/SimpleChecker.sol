// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IAzuranceChecker.sol";
import "./interfaces/IAzurancePool.sol";

contract SimpleChecker is IAzuranceChecker {
    
    function checkUnlockClaim(address target) external override {
        IAzurancePool(target).unlockClaim();
    }

    function checkUnlockTerminate(address target) external override {
        IAzurancePool(target).unlockTerminate();
    }
}
