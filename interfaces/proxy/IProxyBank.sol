// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IProxyBank {
    function owner() external view returns (address);
    
    function setBlacklist(address _account, bool _newset) external;
    function setEmergencyEnabled(uint256 _sid, bool _newset) external;
    function claimLength() external view returns (uint256);
    function addClaimPool(address _poolClaim) external;
    function boxesLength() external view returns (uint256);
    function addBox(address _safebox) external;
    function setBoxListed(uint256 _boxid, bool _listed) external;
    function strategyInfoLength() external view returns (uint256 length);
    function strategyIsListed(uint256 _sid) external view returns (bool);
    function setStrategyListed(uint256 _sid, bool _listed) external;
    function addStrategy(address _strategylink, uint256 _pid, bool _blisted) external;

    function depositLPToken(uint256 _sid, uint256 _amount, uint256 _bid, uint256 _bAmount, uint256 _desirePrice, uint256 _slippage) 
            external returns (uint256 lpAmount);
    function deposit(uint256 _sid, uint256[] memory _amount, uint256 _bid, uint256 _bAmount, uint256 _desirePrice, uint256 _slippage)
            external returns (uint256 lpAmount);

    function withdrawLPToken(uint256 _sid, uint256 _rate, uint256 _desirePrice, uint256 _slippage) external;
    function withdraw(uint256 _sid, uint256 _rate, address _toToken, uint256 _desirePrice, uint256 _slippage) external;
    function withdrawLPTokenAndClaim(uint256 _sid, uint256 _rate, 
                                    uint256 _desirePrice, uint256 _slippage, 
                                    uint256 _poolClaimId, uint256[] memory _pidlist) external;
    function withdrawAndClaim(uint256 _sid, uint256 _rate, address _toToken, 
                                uint256 _desirePrice, uint256 _slippage,
                                uint256 _poolClaimId, uint256[] memory _pidlist) external;
    function claim(uint256 _poolClaimId, uint256[] memory _pidlist) external;
    function emergencyWithdraw(uint256 _sid, uint256 _desirePrice, uint256 _slippage) external;
    function liquidation(uint256 _sid, address _account, uint256 _maxDebt) external;
    function getBorrowAmount(uint256 _sid, address _account) external view returns (uint256 value);
    function getDepositAmount(uint256 _sid, address _account) external view returns (uint256 value);

    function boxInfo(uint256 _boxid) external view returns (address);
    function boxIndex(address _boxaddr) external view returns (uint256);
    function boxlisted(address _boxaddr) external view returns (bool);
    
    function strategyInfo(uint256 _sid) external view returns (bool, address, uint256);
    function strategyIndex(address _strategy, uint256 _sid) external view returns (uint256);
}