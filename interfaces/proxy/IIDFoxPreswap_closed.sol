// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IIDFoxPreswap {
    function owner() external view returns (address);

    function swapRouters(address) external view returns (address);
    function defaultSwapRouter() external view returns (address);
    function userHardtop(address) external view returns (uint);
    function userHardtopMax() external view returns (uint);
    function swapMin() external view returns (uint);
    function operBot(address) external view returns (bool);
    function payAmount(address) external view returns (uint);

    function investToken() external view returns (address);
    function idfoxToken() external view returns (address);
    function mintOutRate() external view returns (uint);
    function investDecimals() external view returns (uint);
    function iWHT() external view returns (address);

    function initialize(address _investToken, address _idfoxToken, uint _mintOutRate, address _iWHT, address _defaultSwapRouter) external;

    function setOper(address _oper, bool _enable) external;
    function setMintOutRate(uint _mintOutRate) external;
    function setSwapMin(uint _swapMin) external;

    function getAccountSetLength() external view returns (uint256);
    function getAccountSet(uint256 _pos) external view returns (address);
    function getInvestTokenSetLength() external view returns (uint256);
    function getInvestTokenSet(uint256 _pos) external view returns (address);
    function getAmount(address _router, address _tokenIn, uint _amountIn) external view returns (uint);
    function getRevertAmount(address _router, address _tokenIn, uint256 _amountOut) external view returns (uint256);

    function mintETH(uint _outMin) external payable;
    function mint(address _payToken, uint _amount, uint _outMin) external;
    function mintCross(address _account, address _payToken, uint _amount, uint _value) external;
    function getRouter(address _token) external view returns (address);
    function pending(address _payToken, uint _amountIn) external view returns (uint value);
    function revertPending(address _payToken, uint _amountOut) external view returns (uint value);
    function withdraw(address _token, uint _amount, address _to) external;
}
