// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../../contracts/interfaces/IStrategyV2Pair.sol";

interface IProxyStrategyV2Pair is IStrategyV2Pair {
    function owner() external view returns (address);
    function swapPoolImpl() external view returns (address);
        
    function addPool(uint256 _poolId, address[] memory _collateralToken, address _baseToken)
            external;
    function setPoolConfig(uint256 _pid, string memory _key, uint256 _value)
        external;
    function setMiniRewardAmount(uint256 _pid, uint256 _miniRewardAmount)
        external;
    function poolInfo(uint256 _pid)
        external view returns (address,address,uint256,uint256,uint256,uint256,uint256,uint256);

    // function symbol() external view returns (string memory);
    // function setBuyback(address _iBuyback) external;
    // function setCompAcionPool(address _compActionPool) external;
    // function setRewardsBorrowPool(uint256 _pidborrow) external;

    // function setPriceOperator(address _oper, bool _enable) external;
    // function setFeeds(address[] memory _tokens, address[] memory _feeds) external;
    // function setPrices(address[] memory tokens, uint[] memory prices) external;
    // function getPrice(address _token) external view returns (int);
    // function getUnderlyingPrice(address cToken) external view returns (uint);
}
