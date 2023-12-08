// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../../test/contracts/TestERC20.sol";
import "../../src/SimpleChecker.sol";
import "../../src/AzurancePool.sol";

contract DeployAll is Script {

    uint256 private _secondsPerBlock = 5; // 5 secs for 1 block
    uint256 private _staleTime = block.timestamp + 16 hours;
    uint256 private _maturityTime = block.timestamp + 1 days;

    uint256 private _maturityBlock = _maturityTime * block.number / block.timestamp;
    uint256 private _staleBlock = _staleTime * block.number / block.timestamp;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TestERC20 testERC20 = new TestERC20();
        SimpleChecker checker = new SimpleChecker();

        address _underlyingToken = address(testERC20);
        uint256 _multiplier = 2000000; // 2x
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";

        new AzurancePool(_multiplier, _maturityBlock, _staleBlock, _underlyingToken, _fee, _feeTo, address(checker), _name, _symbol);

        vm.stopBroadcast();
    }

}
