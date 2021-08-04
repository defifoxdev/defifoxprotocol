// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/token/ERC20/IERC20.sol";

interface IProxySafeBoxFox is IERC20 {
    function owner() external view returns (address);

    function token() external view returns (address);
    function symbol() external view returns (string memory);
    function setBuyback(address _iBuyback) external;
    function setCompAcionPool(address _compActionPool) external;
    function setRewardsBorrowPool(uint256 _pidborrow) external;

    // function setPriceOperator(address _oper, bool _enable) external;
    // function setFeeds(address[] memory _tokens, address[] memory _feeds) external;
    // function setPrices(address[] memory tokens, uint[] memory prices) external;
    // function getPrice(address _token) external view returns (int);
    // function getUnderlyingPrice(address cToken) external view returns (uint);
}
