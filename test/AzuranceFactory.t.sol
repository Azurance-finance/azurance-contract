// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AzuranceFactory.sol";
import "../src/AzurancePool.sol";
import "../src/SimpleChecker.sol";
import "./contracts/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract AzuranceFactoryTest is Test {

    AzuranceFactory public factory;
    SimpleChecker public checker;
    TestERC20 public testERC20;

    uint256 private _multiplier = 10000000; // 3x
    uint256 private _multiplierDecimals = 6;

    uint256 private _maturityBlock = 100;
    uint256 private _staleBlock = 90;
    uint256 private _fee = 1000; // 0.01 = 1%
    address private _feeTo = address(this);

    string private _name = "Covid Insurance";
    string private _symbol = "COVID";

    function setUp() public {
        testERC20 = new TestERC20();
        checker = new SimpleChecker();
        factory = new AzuranceFactory();
    }

    function testCreateAzurance() public {
        address pool = factory.createAzuranceContract(_multiplier, _maturityBlock, _staleBlock, address(testERC20), _fee, _feeTo, address(checker), _name, _symbol);
        assertNotEq(pool, address(0));
    }

}
