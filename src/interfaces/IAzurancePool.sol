// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IAzurancePool {
    // Enum for the state of the pool
    enum State {
        Ongoing,
        Claimable,
        Matured,
        Terminated
    }

    // Events
    event InsuranceBought(address indexed buyer, address token, uint256 amount);
    event InsuranceSold(address indexed seller, address token, uint256 amount);
    event StateChanged(State oldState, State newState);
    event Withdrew(address token, uint256 amount, address indexed to);

    // State variables
    function multiplier() external view returns (uint256);
    function multiplierDecimals() external view returns (uint256);
    function maturityBlock() external view returns (uint256);
    function staleBlock() external view returns (uint256);
    function underlyingToken() external view returns (address);
    function fee() external view returns (uint256);
    function feeDecimals() external view returns (uint256);
    function feeTo() external view returns (address);
    function condition() external view returns (address);
    function buyerToken() external view returns (address);
    function sellerToken() external view returns (address);
    function status() external view returns (State);

    // Write Functions
    function buyInsurance(uint256 amount) external;
    function sellInsurance(uint256 amount) external;
    function unlockClaim() external;
    function unlockMaturity() external;
    function unlockTerminate() external;
    function checkUnlockClaim() external;
    function checkUnlockTerminate() external;
    function withdraw(uint256 buyerAmount, uint256 sellerAmount) external;
    function withdrawFee(uint256 amount) external;

    // Read Functions
    function getAmountClaimable(uint256 buyerAmount, uint256 sellerAmount) external view returns (uint256);
    function getAmountMatured(uint256 buyerAmount, uint256 sellerAmount) external view returns (uint256);
    function getAmountTerminated(uint256 buyerAmount, uint256 sellerAmount) external view returns (uint256);
    function totalValueLocked() external view returns (uint256);
    function totalShares() external view returns (uint256);
    function totalSellShare() external view returns (uint256);
    function totalBuyShare() external view returns (uint256);
    function settledShare() external view returns (uint256);
    function settledSellShare() external view returns (uint256);
    function settledBuyShare() external view returns (uint256);
}
