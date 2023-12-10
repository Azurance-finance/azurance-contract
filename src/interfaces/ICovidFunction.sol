// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICovidFunction {
    function acceptOwnership() external;

    function addToWhitelist(address _address) external;

    error EmptyArgs();
    error EmptySource();

    function handleOracleFulfillment(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) external;

    error NoInlineSecrets();
    error OnlyRouterCanFulfill();

    function removeFromWhitelist(address _address) external;

    error UnexpectedRequestID(bytes32 requestId);
    event OwnershipTransferRequested(address indexed from, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event RequestFulfilled(bytes32 indexed id);
    event RequestSent(bytes32 indexed id);
    event Response(
        bytes32 indexed requestId,
        string country,
        bytes response,
        bytes err
    );

    function sendRequest(uint64 subscriptionId, string[] memory args)
        external
        returns (bytes32 requestId);

    function transferOwnership(address to) external;

    function counrtyCovidPercentage(string memory) external view returns (bool);

    function listOfRequestIdxCountry(bytes32)
        external
        view
        returns (string memory);

    function owner() external view returns (address);

    function s_lastError() external view returns (bytes memory);

    function s_lastRequestId() external view returns (bytes32);

    function s_lastResponse() external view returns (bytes memory);

    function whitelist(address) external view returns (bool);
}
