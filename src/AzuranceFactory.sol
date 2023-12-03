// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AzuranceFactory is Ownable {

    constructor() Ownable(msg.sender) {}

    // function createAzuranceContract() external override onlyOwner {
        
    //     emit Deposited(msg.sender, amount);
    // }

}
