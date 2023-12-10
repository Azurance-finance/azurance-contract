// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract MUMBAIMessenger is CCIPReceiver, OwnerIsCreator {
    // Custom errors to provide more descriptive revert messages.
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
    error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
    error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        string text, // The text being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text // The text that was received.
    );

    // =================================================================================================================
    //                                      Lending Demo Contract Variables
    // =================================================================================================================

    bool public isLendingDemo; // Boolean to indicate if this contract is being used for the lending demo.
    uint64 public last_destinationChainSelector;

    bytes32 private lastReceivedMessageId; // Store the last received messageId.
    string private lastReceivedText; // Store the last received text.

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;

    IERC20 private s_linkToken;
    IRouterClient public router;
    uint64 public sourceChainSelector;

    constructor(
        address _router,
        address _link,
        uint256 _sourceSelector
    ) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
        router = IRouterClient(_router);
        sourceChainSelector = uint64(_sourceSelector);
    }

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage // Make sure source chain and sender are allowlisted
    ) internal override {
        lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        lastReceivedText = abi.decode(any2EvmMessage.data, (string));
        uint64 sourceSelector = any2EvmMessage.sourceChainSelector; // abi-decoding of the sent text

        if (
            keccak256(abi.encodePacked(lastReceivedText)) ==
            keccak256(abi.encodePacked("check_lending_status"))
        ) {
            // send a CCIP message to the sender with the lending status
            sendMessageBackPayLINK(
                abi.decode(any2EvmMessage.sender, (address)),
                isLendingDemo ? "lending_is_fine" : "lending_is_locked",
                sourceSelector
            );
        }

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            abi.decode(any2EvmMessage.data, (string))
        );
    }

    function _buildCCIPMessage(
        address _receiver,
        string memory _text,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: abi.encode(_text), // ABI-encoded string
                tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array aas no tokens are transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit
                    Client.EVMExtraArgsV1({gasLimit: 900_000, strict: false})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, string memory text)
    {
        return (lastReceivedMessageId, lastReceivedText);
    }

    receive() external payable {}

    function withdraw(address _beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }

    // =================================================================================================================
    //                                      Lending Demo Contract Functions
    // =================================================================================================================
    function setLendingDemo(bool _isLendingDemo) external onlyOwner {
        isLendingDemo = _isLendingDemo;
    }

    function sendMessageBackPayLINK(
        address _receiver,
        string memory _text,
        uint64 _sourceSelector
    ) internal returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _text,
            address(s_linkToken)
        );

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_sourceSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_sourceSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _sourceSelector,
            _receiver,
            _text,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }
}
