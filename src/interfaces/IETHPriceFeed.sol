// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IETHPriceFeed {
    function calPrice() external returns (int256);

    function getPrice() external view returns (int256);

    function isBelow100USD() external view returns (bool);

    function pricediff() external view returns (int256);

    function startPrice() external view returns (int256);
}
