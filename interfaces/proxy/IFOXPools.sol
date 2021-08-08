// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IFOXPools {
    function owner() external view returns (address);

    function poolLength() external view returns (uint256);
    function totalAllocPoint() external view returns (uint256);
    function rewardPerBlock() external view returns (uint256);

    function add(uint256 _allocPoint, address _lpToken) external;
    function setRewardPerBlock(uint256 _rewardPerBlock) external;
    function setExtendPool(address _extendPool) external;
    function setAllocPoint(uint256 _pid, uint256 _allocPoint) external;
    function setDevAddress(address _devaddr) external;
    function setPoolStartBlock(uint256 _pid, uint256 _startBlock) external;
    function setBlacklist(address _hacker, bool _set) external;
    function setEmergencyWithdrawEnabled(uint256 _pid, bool _set) external;
    function setRewardRestricted(address _hacker, uint256 _rate) external;
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function claim(uint256 _pid) external returns (uint256 value);
    function claimAll() external returns (uint256 value);
    function emergencyWithdraw(uint256 _pid) external;

    function updatePool(uint256 _pid) external;
    function massUpdatePools() external;
    function poolInfo(uint256 _pid) external view returns (address,uint256,uint256,uint256,uint256);
    function userInfo(uint256 _pid,address _user) external view returns (uint256,uint256,uint256);
    function getBlocksReward(uint256 _from, uint256 _to) external view returns (uint256 value);
}
