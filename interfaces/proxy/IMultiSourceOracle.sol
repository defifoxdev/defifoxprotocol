// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IMultiSourceOracle {
    function setPriceOperator(address _oper, bool _enable) external;
    function setFeeds(address[] memory _tokens, address[] memory _feeds) external;
    function setPrices(address[] memory tokens, uint[] memory prices) external;
    function getPrice(address _token) external view returns (int);
    function getUnderlyingPrice(address cToken) external view returns (uint);

    function isPriceOracle() external view returns (bool);
    function opers(address) external view returns (bool);
    function priceFeeds(address) external view returns (address);
    function store(address) external view returns (uint,uint);
}
