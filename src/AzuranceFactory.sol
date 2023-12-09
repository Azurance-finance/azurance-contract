// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./AzurancePool.sol";

contract AzuranceFactory {

    event InsuranceCreated(address indexed creator, address indexed target, address indexed asset);

    function createAzuranceContract(
        uint256 multiplier_,
        uint256 maturityBlock_,
        uint256 staleBlock_,
        address asset_,
        uint256 fee_,
        address feeTo_,
        address condition_,
        string memory name_,
        string memory symbol_
    ) external returns (address) {
        AzurancePool azurancePool = new AzurancePool(multiplier_, maturityBlock_, staleBlock_, asset_, fee_, feeTo_, condition_, name_, symbol_);
        emit InsuranceCreated(msg.sender, address(azurancePool), asset_);
        return address(azurancePool);
    }

}
