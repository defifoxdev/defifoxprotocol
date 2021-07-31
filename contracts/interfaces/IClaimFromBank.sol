// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IClaimFromBank {
    function claimFromBank(address _account, uint256[] memory _pidlist) external returns (uint256 value);
}