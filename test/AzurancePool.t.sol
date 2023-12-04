// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AzurancePool.sol";
import "./contracts/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract AzurancePoolTest is Test {

    AzurancePool public azurancePool;
    TestERC20 public testERC20;

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

    function setUp() public {
        testERC20 = new TestERC20();
        testERC20.mint(address(this), 1000000 * 10 ** testERC20.decimals());
        testERC20.mint(address(1), 1000000 * 10 ** testERC20.decimals());

        uint256 _benefitMultiplier = 2000000; // 2x
        uint256 _maturityBlock = 100;
        uint256 _staleBlock = 90;
        address _underlyingToken = address(testERC20);
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";
        string memory _oracleUrl = "https://google.com";

        azurancePool = new AzurancePool(_benefitMultiplier, _maturityBlock, _staleBlock, _underlyingToken, _fee, _feeTo, _name, _symbol, _oracleUrl);
    }

    function testSellInsurance() public {
        uint _amount = 2 * 100 * 10 ** testERC20.decimals();

        testERC20.approve(address(azurancePool), _amount);
        azurancePool.sellInsurance(_amount);

        assertEq(azurancePool.totalValueLocked(), _amount);
        assertEq(IERC20(azurancePool.sellerToken()).balanceOf(address(this)), _amount);
    }

    function testBuyInsurance() public {
        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * 2);
        azurancePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        assertEq(azurancePool.totalValueLocked(), _amount * 3);
        assertEq(IERC20(azurancePool.buyerToken()).balanceOf(address(this)), _amount);
    }

    function testFail_BuyInsuranceExceedMax() public {
        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * 2);
        azurancePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount + 1);
    }

    function testFail_BuyInsuranceInStaleTime() public {
        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * 2);
        azurancePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        vm.roll(91);

        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);
    }

    function testChangeStateToClaimable() public {
        azurancePool.unlockClaim();
    }

    function testChangeStateToMatured() public {
        vm.roll(101);
        azurancePool.unlockMaturity();
    }

    function testChangeStateToTerminate() public {
        azurancePool.unlockClaim();
    }

    function testFail_ChangeStateFromClaimableToMatured() public {
        azurancePool.unlockClaim();
        azurancePool.unlockMaturity();
    }

    function testFail_ChangeStateFromMaturedToClaimable() public {
        azurancePool.unlockMaturity();
        azurancePool.unlockClaim();
    }

    // Test withdraw on claimable - check seller and buyer token amount
    function testWithdrawClaimable() public {
        uint _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * 2);
        azurancePool.sellInsurance(_amount * 2);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(azurancePool.sellerToken());
        IERC20 buyerToken = IERC20(azurancePool.buyerToken());

        uint _totalBuyerShare = azurancePool.totalBuyShare();
        uint _totalSellerShare = azurancePool.totalSellShare();
        uint _totalShare = azurancePool.totalShare();
        uint _totalValueLocked = azurancePool.totalValueLocked();

        uint _totalBuyerValue = (_totalBuyerShare * azurancePool.benefitMultiplier() * _totalValueLocked) / 10 ** azurancePool.multiplierDecimals() / _totalShare; 
        uint _totalSellerValue = _totalValueLocked - _totalBuyerValue;

        console.log("_totalBuyerShare: ", _totalBuyerShare);
        console.log("_totalSellerShare: ", _totalSellerShare);
        console.log("_totalShare: ", _totalShare);
        console.log("_totalValueLocked: ", _totalValueLocked);
        console.log("_totalBuyerValue: ", _totalBuyerValue);
        console.log("_totalSellerValue: ", _totalSellerValue);

        // console.log("Total value locked: ", azurancePool.totalValueLocked());
        // console.log("Total shares: ", azurancePool.totalShare());

        // console.log("Sell shares: ", sellerToken.balanceOf(address(1)));
        // console.log("Buy shares: ", buyerToken.balanceOf(address(this)));

        // console.log("Sell claimable: ", azurancePool.getAmountClaimable(0, sellerToken.balanceOf(address(1))));
        // console.log("Buy claimable: ", azurancePool.getAmountClaimable(buyerToken.balanceOf(address(this)), 0));

        // azurancePool.unlockClaim();

        // vm.startPrank(address(1));
        // sellerToken.approve(address(azurancePool), sellerToken.balanceOf(address(1)));
        // azurancePool.withdrawClaimable(0, sellerToken.balanceOf(address(1)));
        // uint sellerBalanceAfter = testERC20.balanceOf(address(1));
        // console.log("Seller balance: ", sellerBalanceAfter);
        // vm.stopPrank();

        // buyerToken.approve(address(azurancePool), buyerToken.balanceOf(address(this)));
        // azurancePool.withdrawClaimable(buyerToken.balanceOf(address(this)), 0);
        // uint buyerBalanceAfter = testERC20.balanceOf(address(this));
        // console.log("Buyer balance: ", buyerBalanceAfter);

        // assertLt(sellerBalanceAfter, _initialBalance);
        // assertGt(buyerBalanceAfter, _initialBalance);
    }

    // Test withdraw on matured
    // Test withdraw on terminated

}
