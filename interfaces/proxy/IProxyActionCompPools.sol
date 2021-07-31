// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IProxyActionCompPools {
    function owner() external view returns (address);

    function add(address _callFrom, uint256 _callId, 
                address _rewardToken, uint256 _maxPerBlock) external;

    function getPoolInfo(uint256 _pid) external view 
        returns (address callFrom, uint256 callId, address rewardToken);
    function mintRewards(uint256 _callId) external;
    function getPoolIndex(address _callFrom, uint256 _callId) external view returns (uint256[] memory);

}
