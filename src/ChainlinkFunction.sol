// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
// import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
// import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

// /**
//  * Request testnet LINK and ETH here: https://faucets.chain.link/
//  * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/resources/link-token-contracts/
//  */

// /**
//  * @title GettingStartedFunctionsConsumer
//  * @notice This is an example contract to show how to make HTTP requests using Chainlink
//  * @dev This contract uses hardcoded values and should not be used in production.
//  */
// contract GettingStartedFunctionsConsumer is FunctionsClient, ConfirmedOwner {
//     using FunctionsRequest for FunctionsRequest.Request;

//     // State variables to store the last request ID, response, and error
//     bytes32 public s_lastRequestId;
//     bytes public s_lastResponse;
//     bytes public s_lastError;

//     // Custom error type
//     error UnexpectedRequestID(bytes32 requestId);

//     // Event to log responses
//     event Response(
//         bytes32 indexed requestId,
//         string country,
//         bytes response,
//         bytes err
//     );

//     // Router address - Hardcoded for Mumbai
//     // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
//     address router = 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C;

//     string source =
//         "const country = args[0];"
//         "const apiResponse = await Functions.makeHttpRequest({"
//         "url: `https://disease.sh/v3/covid-19/countries/${country}?strict=true`"
//         "});"
//         "if (apiResponse.error) {"
//         "throw Error(`Request failed`);"
//         "}"
//         "const { data } = apiResponse;"
//         "const percentage = (data.active/data.population) * 100 ;"
//         "if( percentage > 50 ){"
//         "return Functions.encodeString(`True`);"
//         "}else{"
//         "return Functions.encodeString(`False`);"
//         "}";

//     //Callback gas limit
//     uint32 gasLimit = 300000;

//     // donID - Hardcoded for Mumbai
//     // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
//     bytes32 donID =
//         0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000;

//     /**
//      * @notice Initializes the contract with the Chainlink router address and sets the contract owner
//      */
//     constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

//     mapping(address => bool) public whitelist;

//     mapping(string => bool) public counrtyCovidPercentage;

//     mapping(bytes32 => string) public listOfRequestIdxCountry;

//     modifier onlyWhitelisted() {
//         require(whitelist[msg.sender], "Sender is not whitelisted");
//         _;
//     }

//     function addToWhitelist(address _address) public onlyOwner {
//         whitelist[_address] = true;
//     }

//     function removeFromWhitelist(address _address) public onlyOwner {
//         whitelist[_address] = false;
//     }

//     function changeCovidStatus(string memory country) public onlyOwner {
//         counrtyCovidPercentage[country] = true;
//     }

//     /**
//      * @notice Sends an HTTP request for character information
//      * @param subscriptionId The ID for the Chainlink subscription
//      * @param args The arguments to pass to the HTTP request
//      * @return requestId The ID of the request
//      */
//     function sendRequest(uint64 subscriptionId, string[] calldata args)
//         external
//         onlyWhitelisted
//         returns (bytes32 requestId)
//     {
//         FunctionsRequest.Request memory req;
//         req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
//         if (args.length > 0) req.setArgs(args); // Set the arguments for the request

//         // Send the request and store the request ID
//         s_lastRequestId = _sendRequest(
//             req.encodeCBOR(),
//             subscriptionId,
//             gasLimit,
//             donID
//         );
//         listOfRequestIdxCountry[s_lastRequestId] = args[0];
//         return s_lastRequestId;
//     }

//     /**
//      * @notice Callback function for fulfilling a request
//      * @param requestId The ID of the request to fulfill
//      * @param response The HTTP response data
//      * @param err Any errors from the Functions request
//      */
//     function fulfillRequest(
//         bytes32 requestId,
//         bytes memory response,
//         bytes memory err
//     ) internal override {
//         if (s_lastRequestId != requestId) {
//             revert UnexpectedRequestID(requestId); // Check if request IDs match
//         }
//         // Update the contract's state variables with the response and any errors
//         s_lastResponse = response;
//         s_lastError = err;

//         string memory countyName = listOfRequestIdxCountry[requestId];
//         if (keccak256(abi.encodePacked(string(response))) == keccak256(abi.encodePacked("true"))) {
//             counrtyCovidPercentage[countyName] = true;
//         } else if (keccak256(abi.encodePacked(string(response))) == keccak256(abi.encodePacked("false"))) {
//             counrtyCovidPercentage[countyName] = false;
//         }

//         // Emit an event to log the response
//         emit Response(requestId, countyName, s_lastResponse, s_lastError);
//     }
// }
