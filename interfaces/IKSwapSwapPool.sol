// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.8.0;

// https://www.oklink.com/okexchain/address/0x1fcceabcd2ddadea61ae30a2f1c2d67a05fdda29

interface IKSwapSwapPool {
    function kst() external view returns (address);
    function harvestAll() external ;
}
