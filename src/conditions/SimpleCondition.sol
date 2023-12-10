// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../interfaces/IAzuranceCondition.sol";
import "../interfaces/IAzurancePool.sol";

contract SimpleCondition is IAzuranceCondition {
    
    function checkUnlockClaim(address target) external override {
        IAzurancePool(target).unlockClaim();
    }

    function checkUnlockTerminate(address target) external override {
        IAzurancePool(target).unlockTerminate();
    }
}
