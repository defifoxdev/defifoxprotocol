// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ITenBankHall {
    function makeBorrowFrom(uint256 _pid, address _account, address _debtFrom, uint256 _value) external returns (uint256 bid);
}