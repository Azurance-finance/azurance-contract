// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MintableERC20 is ERC20, Ownable {
    
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {}

    function mint(address _account, uint _value) external onlyOwner {
        _mint(_account, _value);
    }

    function burn(address _account, uint _value) external onlyOwner {
        _burn(_account, _value);
    }
}
