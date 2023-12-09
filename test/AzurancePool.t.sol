// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/AzuranceFactory.sol";
import "../src/AzurancePool.sol";
import "../src/SimpleCondition.sol";
import "./contracts/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract AzurancePoolTest is Test {

    AzuranceFactory public factory;
    AzurancePool public azurancePool;
    SimpleCondition public condition;
    TestERC20 public testERC20;

    uint256 private _multiplier = 10000000; // 3x
    uint256 private _multiplierDecimals = 6;

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

        factory = new AzuranceFactory();
        condition = new SimpleCondition();

        uint256 _maturityBlock = 100;
        uint256 _staleBlock = 90;
        address _underlyingToken = address(testERC20);
        uint256 _fee = 1000; // 0.01 = 1%
        address _feeTo = address(this);

        string memory _name = "Covid Insurance";
        string memory _symbol = "COVID";

        address _pool = factory.createAzuranceContract(_multiplier, _maturityBlock, _staleBlock, _underlyingToken, _fee, _feeTo, address(condition), _name, _symbol);
        azurancePool = AzurancePool(_pool);
    }

    function testSellInsurance() public {
        uint _amount = 100 * 10 ** testERC20.decimals();

        testERC20.approve(address(azurancePool), _amount);
        azurancePool.sellInsurance(_amount);

        assertEq(azurancePool.totalValueLocked(), _amount);
        assertEq(IERC20(azurancePool.sellerToken()).balanceOf(address(this)), _amount);
    }

    function testBuyInsurance() public {
        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        azurancePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        assertEq(azurancePool.totalValueLocked(), _amount + _amount * _multiplier / 10 ** _multiplierDecimals);
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
        azurancePool.checkUnlockClaim();
    }

    function testChangeStateToMatured() public {
        vm.roll(101);
        azurancePool.unlockMaturity();
    }

    function testChangeStateToTerminate() public {
        azurancePool.checkUnlockTerminate();
    }

    function testFail_ChangeStateFromClaimableToMatured() public {
        azurancePool.checkUnlockClaim();
        azurancePool.unlockMaturity();
    }

    function testFail_ChangeStateFromMaturedToClaimable() public {
        azurancePool.unlockMaturity();
        azurancePool.checkUnlockClaim();
    }

    // Test withdraw on claimable - check seller and buyer token amount
    function testWithdrawClaimable() public {
        uint _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        azurancePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(azurancePool.sellerToken());
        IERC20 buyerToken = IERC20(azurancePool.buyerToken());

        azurancePool.checkUnlockClaim();

        vm.startPrank(address(1));
        sellerToken.approve(address(azurancePool), sellerToken.balanceOf(address(1)));
        azurancePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(azurancePool), buyerToken.balanceOf(address(this)));
        azurancePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertLt(sellerBalanceAfter, _initialBalance);
        assertGt(buyerBalanceAfter, _initialBalance);
    }

    // Test withdraw on matured
    function testWithdrawMatured() public {
        uint _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        azurancePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(azurancePool.sellerToken());
        IERC20 buyerToken = IERC20(azurancePool.buyerToken());

        vm.roll(101);
        azurancePool.unlockMaturity();

        vm.startPrank(address(1));
        sellerToken.approve(address(azurancePool), sellerToken.balanceOf(address(1)));
        azurancePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(azurancePool), buyerToken.balanceOf(address(this)));
        azurancePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertLt(buyerBalanceAfter, _initialBalance);
        assertGt(sellerBalanceAfter, _initialBalance);
    }

    // Test withdraw on terminated
    function testWithdrawTerminated() public {
        uint _initialBalance = 1000000 * 10 ** testERC20.decimals();

        uint _amount = 100 * 10 ** testERC20.decimals();
        vm.startPrank(address(1));
        testERC20.approve(address(azurancePool), _amount * _multiplier / 10 ** _multiplierDecimals);
        azurancePool.sellInsurance(_amount * _multiplier / 10 ** _multiplierDecimals);

        vm.stopPrank();
        testERC20.approve(address(azurancePool), _amount);
        azurancePool.buyInsurance(_amount);

        IERC20 sellerToken = IERC20(azurancePool.sellerToken());
        IERC20 buyerToken = IERC20(azurancePool.buyerToken());

        azurancePool.checkUnlockTerminate();

        vm.startPrank(address(1));
        sellerToken.approve(address(azurancePool), sellerToken.balanceOf(address(1)));
        azurancePool.withdraw(0, sellerToken.balanceOf(address(1)));
        uint sellerBalanceAfter = testERC20.balanceOf(address(1));
        vm.stopPrank();

        buyerToken.approve(address(azurancePool), buyerToken.balanceOf(address(this)));
        azurancePool.withdraw(buyerToken.balanceOf(address(this)), 0);
        uint buyerBalanceAfter = testERC20.balanceOf(address(this));

        assertEq(buyerBalanceAfter, _initialBalance);
        assertEq(sellerBalanceAfter, _initialBalance);
    }

}
