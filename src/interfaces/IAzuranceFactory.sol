// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IAzuranceFactory {
    function createAzuranceContract(
        uint256 multiplier_,
        uint256 maturityBlock_,
        uint256 staleBlock_,
        address asset_,
        uint256 fee_,
        address feeTo_,
        address checker_,
        string memory name_,
        string memory symbol_
    ) external returns (address);
}
