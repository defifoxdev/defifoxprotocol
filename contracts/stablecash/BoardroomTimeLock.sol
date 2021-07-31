// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/access/Ownable.sol";
import "@openzeppelinBase/contracts/GSN/Context.sol";
import "@openzeppelinBase/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelinBase/contracts/token/ERC20/IERC20.sol";
import "@openzeppelinBase/contracts/math/SafeMath.sol";

import "./lib/Safe112.sol";
import "./lib/ContractGuard.sol";
import "./lib/IBasisAsset.sol";
import "./lib/Operator.sol";

contract ShareWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public share;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        share.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        uint256 directorShare = _balances[msg.sender];
        require(
            directorShare >= amount,
            'Boardroom: withdraw request greater than staked amount'
        );
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = directorShare.sub(amount);
        share.safeTransfer(msg.sender, amount);
    }
}

contract Boardroom is ShareWrapper, ContractGuard, Operator {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using Safe112 for uint112;

    /* ========== DATA STRUCTURES ========== */

    struct Boardseat {
        uint256 lastSnapshotIndex;
    }

    struct BoardSnapshot {
        uint256 time;
        uint256 rewardReceived;
        uint256 rewardPerShare;
    }

    /* ========== STATE VARIABLES ========== */

    IERC20 public cash;
    uint256 public timeLock;

    mapping(address => Boardseat) private directors;
    BoardSnapshot[] private boardHistory;

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC20 _cash, IERC20 _share) public {
        cash = _cash;
        share = _share;

        BoardSnapshot memory genesisSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: 0,
            rewardPerShare: 0
        });
        boardHistory.push(genesisSnapshot);
    }

    /* ========== Modifiers =============== */
    modifier directorExists {
        require(
            balanceOf(msg.sender) > 0,
            'Boardroom: The director does not exist'
        );
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // =========== Snapshot getters

    function latestSnapshotIndex() public view returns (uint256) {
        return boardHistory.length.sub(1);
    }

    function getLatestSnapshot() internal view returns (BoardSnapshot memory) {
        return boardHistory[latestSnapshotIndex()];
    }

    function getLastSnapshotIndexOf(address director)
        public
        view
        returns (uint256)
    {
        return directors[director].lastSnapshotIndex;
    }

    function getLastSnapshotOf(address director)
        internal
        view
        returns (BoardSnapshot memory)
    {
        return boardHistory[getLastSnapshotIndexOf(director)];
    }

    // =========== Director getters

    function rewardPerShare() public view returns (uint256) {
        return getLatestSnapshot().rewardPerShare;
    }

    function earned(address director) public view returns (uint256) {
        uint256 latestRPS = getLatestSnapshot().rewardPerShare;
        uint256 storedRPS = getLastSnapshotOf(director).rewardPerShare; 

        return
            balanceOf(director).mul(latestRPS.sub(storedRPS)).div(1e18);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount)
        public
        override
        onlyOneBlock
    {
        require(amount > 0, 'Boardroom: Cannot stake 0');
        claimReward();
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        override
        onlyOneBlock
        directorExists
    {
        require(amount > 0, 'Boardroom: Cannot withdraw 0');
        require(block.timestamp >= timeLock,"Boardroom: Withdraw Time Lockd");
        claimReward();
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function claimReward() public {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            cash.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
        directors[msg.sender].lastSnapshotIndex = latestSnapshotIndex();
    }

    function allocateSeigniorage(uint256 amount)
        external
        onlyOneBlock
        onlyOperator
    {
        require(amount > 0, 'Boardroom: Cannot allocate 0');
        require(totalSupply() > 0,
            'Boardroom: Cannot allocate when totalSupply is 0'
        );

        // Create & add new snapshot
        uint256 prevRPS = getLatestSnapshot().rewardPerShare;
        uint256 nextRPS = prevRPS.add(amount.mul(1e18).div(totalSupply()));

        BoardSnapshot memory newSnapshot = BoardSnapshot({
            time: block.number,
            rewardReceived: amount,
            rewardPerShare: nextRPS
        });
        boardHistory.push(newSnapshot);

        cash.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardAdded(msg.sender, amount);
    }
    
    function burnReward() 
        external         
        onlyOneBlock
        onlyOperator 
    {
        for(uint256 i = 0;i<boardHistory.length;i++){
            boardHistory[i].rewardPerShare = 0;
        }
        IERC20 _cash = IERC20(cash);
        uint256 boardBalance = _cash.balanceOf(address(this));
        if (boardBalance > 0){
            // transfer treasury
            _cash.transfer(operator(),boardBalance);
        }
    }

    function setTimeLock(uint256 time) external onlyOperator {
        timeLock = time;
    }

    /* ========== EVENTS ========== */
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardAdded(address indexed user, uint256 reward);
}