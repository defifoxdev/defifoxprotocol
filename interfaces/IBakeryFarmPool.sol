// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

interface IBakeryFarmPool {

    function bake() external view returns (address);

    function poolInfoMap(address _pid) external view returns(uint256, uint256, uint256, bool);

    function poolUserInfoMap(address _pid, address _user) external view returns (uint256, uint256, uint256);

    function deposit(address _pid, uint256 _amount) external;

    function pendingBake(address _pid, address _user) external view returns (uint256);

    function withdraw(address _pid, uint256 _amount) external;

    function emergencyWithdraw(address _pid) external;

    function poolLength() external view returns (uint256);

    function poolAddresses(uint256 _pindex) external view returns (address);
}
