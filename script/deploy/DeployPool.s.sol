// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/TestERC20.sol";
import "../../src/SimpleChecker.sol";
import "../../src/AzurancePool.sol";
import "../../src/interfaces/IAzuranceFactory.sol";

contract DeployPool is Script {

    uint256 private _secondsPerBlock = 5; // 5 secs for 1 block
    uint256 private _staleTime = block.timestamp + 16 hours;
    uint256 private _maturityTime = block.timestamp + 1 days;

    uint256 private _maturityBlock = _maturityTime * block.number / block.timestamp;
    uint256 private _staleBlock = _staleTime * block.number / block.timestamp;

    address private _asset = 0x02C23A6ecFAC21B1409FD78684a614Dd78F2B6b7;
    address private _checker = 0x927B303A496b273f3E90Ce01c54C9f9b7F5A76C2;

    IAzuranceFactory private _factory = IAzuranceFactory(0x77d51D3B08aB7C1d5253513982a2FDb0A8550072);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 _multiplier = 2000000; // 2x
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";

        _factory.createAzuranceContract(_multiplier, _maturityBlock, _staleBlock, _asset, _fee, _feeTo, _checker, _name, _symbol);

        vm.stopBroadcast();
    }

}
