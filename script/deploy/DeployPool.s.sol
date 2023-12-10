// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/TestERC20.sol";
import "../../src/SimpleCondition.sol";
import "../../src/AzurancePool.sol";
import "../../src/interfaces/IAzuranceFactory.sol";

contract DeployPool is Script {

    uint256 private _secondsPerBlock = 5; // 5 secs for 1 block
    uint256 private _staleTime = block.timestamp + 16 hours;
    uint256 private _maturityTime = block.timestamp + 1 days;

    uint256 private _maturityBlock = _maturityTime * block.number / block.timestamp;
    uint256 private _staleBlock = _staleTime * block.number / block.timestamp;

    address private _asset = 0xb0b001478b069FaC8b849c237f0c0fba790aA630;
    address private _condition = 0xb0b001478b069FaC8b849c237f0c0fba790aA630;

    IAzuranceFactory private _factory = IAzuranceFactory(0x2DA1A7AaB838960a49AC0D62480aD3412b2E8B5B);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 _multiplier = 2000000; // 2x
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";

        _factory.createAzuranceContract(_multiplier, _maturityBlock, _staleBlock, _asset, _fee, _feeTo, _condition, _name, _symbol);

        vm.stopBroadcast();
    }

}
