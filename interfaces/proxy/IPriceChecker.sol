// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPriceChecker {
    function setLargeSlipRate(uint256 _largeSlipRate) external;
    function setPriceSlippage(address _lptoken, uint256 _slippage) external;
    function setTokenOracle(address _tokenOracle) external;
    function getPriceSlippage(address _lptoken) external view returns (uint256);
    function getLPTokenPriceInMdex(address _lptoken, address _t0, address _t1) external view returns (uint256);
    function getLPTokenPriceInOracle(address _t0, address _t1) external view returns (uint256);
    function checkLPTokenPriceLimit(address _lptoken, bool _largeType) external view returns (bool);
}
