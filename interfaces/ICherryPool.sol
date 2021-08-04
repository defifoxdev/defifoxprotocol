// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

interface ICherryPool {
    function cherry() external view returns (address);

    function poolLength() external view returns (uint256);

    function poolInfo(uint256 _pid) external view returns(address _lpToken, uint256, uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256 _amount, uint256 _rewardDebt);

    function deposit(uint256 _pid, uint256 _amount) external;

    function pendingCherry(uint256 _pid, address _user) external view returns (uint256);

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;
}
