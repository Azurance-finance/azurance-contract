// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

import "../interfaces/IAzuranceCondition.sol";
import "../interfaces/IAzurancePool.sol";

contract CovidCondition is IAzuranceCondition, FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;

    // donID - Hardcoded for Fuji
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donID =
        0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000;
    uint32 gasLimit = 300000;

    uint64 subscriptionId;
    mapping(bytes32 => address) public requestTarget;

    string source =
        "const country = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://disease.sh/v3/covid-19/countries/${country}?strict=true`"
        "});"
        "if (apiResponse.error) {"
        "throw Error(`Request failed`);"
        "}"
        "const { data } = apiResponse;"
        "const percentage = Math.floor((data.active*Math.pow(10,18)/data.population));"
        "return Functions.encodeUint256(percentage);";

    error UnexpectedRequestID(bytes32 requestId);

    event Response(
        bytes32 indexed requestId,
        address target,
        bytes response,
        bytes err
    );

    constructor(uint64 subscriptionId_) FunctionsClient(router) ConfirmedOwner(msg.sender) {
        subscriptionId = subscriptionId_;
    }
    
    function checkUnlockClaim(address target) external override {
        require(msg.sender == target, "The contract must check itselfs");

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); 

        string[] memory args = new string[](1);
        args[0] = "th";
        req.setArgs(args);

        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        requestTarget[s_lastRequestId] = target;
    }

    function checkUnlockTerminate(address target) external override {
        // For demo purpose only. Please add a strict condition on production
        IAzurancePool(target).unlockTerminate();
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }
        s_lastResponse = response;
        s_lastError = err;

        uint percentage = uint256(bytes32(response));
        address target = requestTarget[requestId];

        if (percentage >= 30 * 10**18) {
            IAzurancePool(target).unlockClaim();
        }

        // Emit an event to log the response
        emit Response(requestId, target, s_lastResponse, s_lastError);
    }
}
