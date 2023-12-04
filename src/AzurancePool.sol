// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MintableERC20.sol";
import "./interfaces/IAzurancePool.sol";

contract AzurancePool is IAzurancePool {
    uint256 private _benefitMultiplier;
    uint256 private _maturityBlock;
    uint256 private _staleBlock;
    string private _oracleUrl;

    uint256 private _fee;
    address private _feeTo;

    IERC20 private _underlyingToken;
    MintableERC20 private _buyerToken;
    MintableERC20 private _sellerToken;

    State private _status;

    // Constructor
    constructor(
        uint256 benefitMultiplier_,
        uint256 maturityBlock_,
        uint256 staleBlock_,
        address underlyingToken_,
        uint256 fee_,
        address feeTo_,
        string memory name_,
        string memory symbol_,
        string memory oracleUrl_
    ) {
        _benefitMultiplier = benefitMultiplier_;
        _maturityBlock = maturityBlock_;
        _staleBlock = staleBlock_;

        _oracleUrl = oracleUrl_;
        _fee = fee_;
        _feeTo = feeTo_;

        _underlyingToken = IERC20(underlyingToken_);
        _buyerToken = new MintableERC20(
            string.concat(name_, "-BUY"),
            string.concat(symbol_, "-BUY")
        );
        _sellerToken = new MintableERC20(
            string.concat(name_, "-SELL"),
            string.concat(symbol_, "-SELL")
        );

        _status = State.Ongoing;
    }

    modifier onlyNotStale() {
        require(block.number <= _staleBlock, "Pansurance: Stale block passed");
        _;
    }

    modifier onlyState(State _state) {
        require(_status == _state, "Pansurance: Invalid state");
        _;
    }

    // Write Functions
    function buyInsurance(
        uint256 _amount
    ) external override onlyNotStale onlyState(State.Ongoing) {
        // Gas savings
        uint _totalShare = totalShare();

        uint _share = 0;
        if (_totalShare == 0) {
            _share = _amount;
        } else {
            _share = (_amount * _totalShare) / totalValueLocked();
        }

        require(
            (_totalBuyShare() + _share) * _benefitMultiplier / 10 ** multiplierDecimals() <= _totalSellShare(),
            "Exceed buy deposit"
        );

        _underlyingToken.transferFrom(msg.sender, address(this), _amount);
        _buyerToken.mint(msg.sender, _share);

        emit InsuranceBought(msg.sender, address(_underlyingToken), _amount);
    }

    function sellInsurance(
        uint256 _amount
    ) external override onlyNotStale onlyState(State.Ongoing) {
        // Gas savings
        uint _totalShare = totalShare();

        uint _shares = 0;
        if (_totalShare == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount * _totalShare) / totalValueLocked();
        }

        _underlyingToken.transferFrom(msg.sender, address(this), _amount);
        _sellerToken.mint(msg.sender, _shares);

        emit InsuranceSold(msg.sender, address(_underlyingToken), _amount);
    }

    function unlockClaim() external override onlyState(State.Ongoing) {
        // Check from oracle
        _status = State.Claimable;
        emit StateChanged(State.Ongoing, State.Claimable);
    }

    function unlockMaturity() external override onlyState(State.Ongoing) {
        require(block.number > _maturityBlock, "Maturity time not met");
        _status = State.Matured;
        emit StateChanged(State.Ongoing, State.Matured);
    }

    function unlockTerminate() external override onlyState(State.Ongoing) {
        // Check oracle fail
        _status = State.Terminated;
        emit StateChanged(State.Ongoing, State.Terminated);
    }

    function withdrawClaimable(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) external override onlyState(State.Claimable) {
        uint256 _withdrewAmount = getAmountClaimable(_buyerAmount, _sellerAmount);
        _withdraw(_buyerAmount, _sellerAmount, _withdrewAmount);
        emit Withdrew(address(_underlyingToken), _withdrewAmount, msg.sender);
    }

    function withdrawMatured(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) external override onlyState(State.Matured) {
        uint256 _withdrewAmount = getAmountMatured(_buyerAmount, _sellerAmount);
       _withdraw(_buyerAmount, _sellerAmount, _withdrewAmount);
        emit Withdrew(address(_underlyingToken), _withdrewAmount, msg.sender);
    }

    function withdrawTerminated(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) external override onlyState(State.Terminated) {
        uint256 _withdrewAmount = getAmountTerminated(
            _buyerAmount,
            _sellerAmount
        );
        _withdraw(_buyerAmount, _sellerAmount, _withdrewAmount);
        emit Withdrew(address(_underlyingToken), _withdrewAmount, msg.sender);
    }

    function withdrawFee(uint256 _amount) external {
        require(_status != State.Ongoing, "Pansurance: Contract is ongoing");
        // Logic to withdraw platform fees
    }

    // Read Functions
    function getAmountClaimable(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) public view override returns (uint256) {
        // Gas savings
        uint _totalBuyerShare = totalBuyShare();
        uint _totalSellerShare = totalSellShare();
        uint _totalShare = totalShare();
        uint _totalValueLocked = totalValueLocked();

        uint _totalBuyerValue = (_totalBuyerShare * _benefitMultiplier * _totalValueLocked) / 10 ** multiplierDecimals() / _totalShare; 
        uint _totalSellerValue = _totalValueLocked - _totalBuyerValue;

        uint _withdrewAmount = 0;
        if (_buyerAmount > 0) {
            _withdrewAmount += _getPortion(
                _buyerAmount,
                _totalBuyerShare,
                _totalBuyerValue
            );
        }
        if (_sellerAmount > 0) {
            _withdrewAmount += _getPortion(
                _sellerAmount,
                _totalSellerShare,
                _totalSellerValue
            );
        }

        return _withdrewAmount;
    }

    function getAmountMatured(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) public view override returns (uint256) {
        // Gas savings
        uint _totalBuyerShare = totalBuyShare();
        uint _totalSellerShare = totalSellShare();
        uint _totalShare = totalShare();
        uint _totalValueLocked = totalValueLocked();

        uint _totalSellerValue = (_totalValueLocked *
            (_totalSellerShare +
                (_totalBuyerShare *
                    (_benefitMultiplier - 10 ** multiplierDecimals())) /
                _benefitMultiplier)) / _totalShare / 10 ** multiplierDecimals();

        uint _totalBuyerValue = _totalValueLocked - _totalSellerValue;

        uint _withdrewAmount = 0;
        if (_buyerAmount > 0) {
            _withdrewAmount += _getPortion(
                _buyerAmount,
                _totalBuyerShare,
                _totalBuyerValue
            );
        }
        if (_sellerAmount > 0) {
            _withdrewAmount += _getPortion(
                _sellerAmount,
                _totalSellerShare,
                _totalSellerValue
            );
        }

        return _withdrewAmount;
    }

    function getAmountTerminated(
        uint256 _buyerAmount,
        uint256 _sellerAmount
    ) public view override returns (uint256) {
        // Gas savings
        uint _totalBuyerShare = totalBuyShare();
        uint _totalSellerShare = totalSellShare();
        uint _totalShare = totalShare();
        uint _totalValueLocked = totalValueLocked();

        uint _totalBuyerValue = (_totalBuyerShare * _totalValueLocked) /
            _totalShare;
        uint _totalSellerValue = (_totalSellerShare * _totalValueLocked) /
            _totalShare;

        uint _withdrewAmount = 0;
        if (_buyerAmount > 0) {
            _withdrewAmount += _getPortion(
                _buyerAmount,
                _totalBuyerShare,
                _totalBuyerValue
            );
        }
        if (_sellerAmount > 0) {
            _withdrewAmount += _getPortion(
                _sellerAmount,
                _totalSellerShare,
                _totalSellerValue
            );
        }

        return _withdrewAmount;
    }

    function totalValueLocked() public view override returns (uint256) {
        return _totalValueLocked();
    }

    function totalShare() public view override returns (uint256) {
        return _totalShare();
    }

    function totalBuyShare() public view override returns (uint256) {
        return _totalBuyShare();
    }

    function totalSellShare() public view override returns (uint256) {
        return _totalSellShare();
    }

    function multiplierDecimals() public view override returns (uint256) {
        return 6;
    }

    function feeDecimals() public view override returns (uint256) {
        return 6;
    }

    function staleBlock() external view override returns (uint256) {
        return _staleBlock;
    }

    function status() external view override returns (State) {
        return _status;
    }

    function underlyingToken() external view override returns (address) {
        return address(_underlyingToken);
    }

    function benefitMultiplier() external view override returns (uint256) {
        return _benefitMultiplier;
    }

    function fee() external view override returns (uint256) {
        return _fee;
    }

    function feeTo() external view override returns (address) {
        return _feeTo;
    }

    function maturityBlock() external view override returns (uint256) {
        return _maturityBlock;
    }

    function oracleUrl() external view override returns (string memory) {
        return _oracleUrl;
    }

    function buyerToken() external view override returns (address) {
        return address(_buyerToken);
    }

    function sellerToken() external view override returns (address) {
        return address(_sellerToken);
    }

    // Internal functions
    function _totalValueLocked() internal view returns (uint256) {
        return _underlyingToken.balanceOf(address(this));
    }

    function _totalShare() internal view returns (uint256) {
        return _totalBuyShare() + _totalSellShare();
    }

    function _totalBuyShare() internal view returns (uint256) {
        return _buyerToken.totalSupply();
    }

    function _totalSellShare() internal view returns (uint256) {
        return _sellerToken.totalSupply();
    }

    function _getPortion(
        uint256 _share,
        uint256 _totalShare,
        uint256 _totalValue
    ) internal pure returns (uint256) {
        return (_share * _totalValue) / _totalShare;
    }

    function _withdraw(uint256 _buyerAmount, uint256 _sellerAmount, uint256 _withdrewAmount) internal {
        if (_buyerAmount > 0) {
            _buyerToken.burn(msg.sender, _buyerAmount);
        }
        if (_sellerAmount > 0) {
            _sellerToken.burn(msg.sender, _sellerAmount);
        }
        require(_withdrewAmount > 0, "Amount out must be greater than 0");
        _transferOut(_withdrewAmount);
    }

    function _transferOut(uint256 _amount) internal virtual {
       _underlyingToken.transfer(msg.sender, _amount);
    }
}
