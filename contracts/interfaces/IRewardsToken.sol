// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IRewardsToken {
    function mint(address _account, uint256 _amount) external;
    function burn(uint256 _amount) external;

    function setMintWhitelist(address _account, bool _enabled) external;
    function checkWhitelist(address _account) external view returns (bool);
}