// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../../contracts/interfaces/IPriceChecker.sol";

interface IProxyPriceChecker is IPriceChecker {
    function owner() external view returns (address);

    function setLargeSlipRate(uint256 _largeSlipRate) external;
    function setTokenOracle(address _tokenOracle) external;
    function setPriceSlippage(address _lptoken, uint256 _slippage) external;

    function tokenOracle() external view returns (address);

    function getLPTokenPriceInOracle(address _t0, address _t1) external view returns (uint256);
    function getLPTokenPriceInMdex(address _lptoken, address _t0, address _t1) external view returns (uint256);
    // function checkLPTokenPriceLimit(address _lptoken, bool _largeType) external view returns (bool);
}