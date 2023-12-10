// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IAzuranceCondition.sol";
import "./interfaces/IAzurancePool.sol";
import "./interfaces/ICovidFunction.sol";

contract CovidCondition is IAzuranceCondition {
    ICovidFunction public covidFunction;

    constructor(address _covidFunctionAddress) {
        covidFunction = ICovidFunction(_covidFunctionAddress);
    }

    function checkUnlock(
        uint64 subscriptionId,
        string[] memory args
    ) internal returns (bytes32 requestId) {
        if (args.length == 0) {
            revert ICovidFunction.EmptyArgs();
        }

        string memory character = args[0];
        if (bytes(character).length == 0) {
            revert ICovidFunction.EmptySource();
        }

        requestId = covidFunction.sendRequest(subscriptionId, args);
    }

    function checkUnlockClaim(address target) public override {
        string[] memory args = new string[](1);
        args[0] = "th";
        checkUnlock(1170, args);
        string memory county = covidFunction.listOfRequestIdxCountry(
            covidFunction.s_lastRequestId()
        );
        if (covidFunction.counrtyCovidPercentage(county)) {
            IAzurancePool(target).unlockClaim();
        } else {
            revert("CovidCondition: Covid percentage is not enough");
        }
    }

    function checkUnlockTerminate(address target) external override {
        IAzurancePool(target).unlockTerminate();
    }
}
