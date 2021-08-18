// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IProxyActionCompPools {
    function owner() external view returns (address);

    function add(address _callFrom, uint256 _callId, 
                address _rewardToken, uint256 _maxPerBlock) external;

    function getPoolInfo(uint256 _pid) external view 
        returns (address callFrom, uint256 callId, address rewardToken);
    function getPoolIndex(address _callFrom, uint256 _callId) external view returns (uint256[] memory);

    // function massUpdatePools(uint256 _start, uint256 _end) external;
    function tokenTotalRewards(address _token) external view returns (uint256);
    function rewardRestricted(address _token) external view returns (uint256);
    function eventSources(address _token) external view returns (bool);
    function mintTokens(address _token) external view returns (uint256);
    function boodev() external view returns (address);
    function bank() external view returns (address);

    function poolLength() external view returns (uint256);

    // Set the number of reward produced by each block
    function setRewardMaxPerBlock(uint256 _pid, uint256 _maxPerBlock) external;
    function setMintTokens(address[] memory _mintTokens, uint256[] memory _mintFee) external;

    function setAutoUpdate(uint256 _pid, bool _set) external;
    function setAutoClaim(uint256 _pid, bool _set) external;
    
    function setRewardRestricted(address _hacker, uint256 _rate) external;
    function setBooDev(address _boodev) external;

    // Return reward multiplier over the given _from to _to block.
    function getBlocksReward(uint256 _pid, uint256 _from, uint256 _to) external view returns (uint256 value);

    // View function to see pending Tokens on frontend.
    function pendingRewards(uint256 _pid, address _account) external view returns (uint256 value);

    function pendingRewards(uint256 _pid, address _account, uint256 _points, uint256 _totalPoints)
            external view returns (uint256 value);
    function totalRewards(uint256 _pid, uint256 _points, uint256 _totalPoints) 
            external view returns (uint256 value);

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools(uint256 _start, uint256 _end) external;

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) external;

    function mintRewards(uint256 _pid) external;
    
    function claimIds(uint256[] memory _pidlist) external returns (uint256 value);
    function claimFromBank(address _account, uint256[] memory _pidlist) external returns (uint256 value);
    function claim(uint256 _pid) external returns (uint256 value);
}
