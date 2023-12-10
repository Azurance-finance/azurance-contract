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

    address private _asset = 0x2cF4D2118e5cBE5c5bB24aF6Ef0492139aca54db;
    address private _condition = 0xCf267365eeC88bfB3de9A69e986cDbaE1B1d8F94;

    IAzuranceFactory private _factory = IAzuranceFactory(0x98BA6640Cf3d3B45dA7773c33BD9558Ad3D79B0a);

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
