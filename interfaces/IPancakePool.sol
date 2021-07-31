// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

// https://bscscan.com/address/0x73feaa1ee314f8c655e354234017be2193c9e24e#code

interface IPancakePool {

    function cake() external view returns (address);

    function poolLength() external view returns (uint256);

    function poolInfo(uint256 _pid) external view returns(address, uint256, uint256, uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

}
