// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../interfaces/IAzuranceCondition.sol";
import "../interfaces/IAzurancePool.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ETHCrashCondition is IAzuranceCondition {

    AggregatorV3Interface internal dataFeed;

    constructor() {
        // Fixed aggregator in Fuji chain
        dataFeed = AggregatorV3Interface(
            0x86d67c3D38D2bCeE722E601025C25a575021c6EA
        );
    }

    function getPrice() public view returns (int256) {
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function isEligible() public view returns (bool) {
        int256 price = getPrice();
        return price < 2500 * (10**8);
    }
    
    function checkUnlockClaim(address target) external override {
        require(msg.sender == target, "Only target can check itself");
        if (isEligible()) {
            IAzurancePool(target).unlockClaim();
        }
    }

    function checkUnlockTerminate(address target) external override {
        // For demo purpose only. Please add a strict condition on production
        IAzurancePool(target).unlockTerminate();
    }
}
