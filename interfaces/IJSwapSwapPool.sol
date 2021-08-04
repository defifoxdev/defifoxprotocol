// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

// https://www.oklink.com/okexchain/address/0x7b16bcab6684923de97202b72e1a17481cf0af4b

interface IJSwapSwapPool {
    function jfToken() external view returns (address);
    function pending(address _user) external view returns (uint256);
    function withdraw() external;
}
