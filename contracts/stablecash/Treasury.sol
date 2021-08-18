// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/access/Ownable.sol";
import "@openzeppelinBase/contracts/GSN/Context.sol";
import "@openzeppelinBase/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelinBase/contracts/token/ERC20/IERC20.sol";
import "@openzeppelinBase/contracts/math/SafeMath.sol";
import "@openzeppelinBase/contracts/math/SignedSafeMath.sol";
import "@openzeppelinBase/contracts/utils/Address.sol";

import "./lib/Math.sol";
import "./lib/Babylonian.sol";
import "./lib/UInt256Lib.sol";
import "./lib/ContractGuard.sol";
import "./lib/Orchestrator.sol";
import "./lib/IBoardroom.sol";
import "./lib/ISimpleERCFund.sol";

import "../interfaces/IRewardsToken.sol";

import "./Epoch.sol";

/**
 * @title Treasury contract
 * @notice Monetary policy logic to adjust supplies of basis cash assets
 * @author Summer Smith & Rick Sanchez
 */
contract Treasury is ContractGuard, Epoch, Orchestrator {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using UInt256Lib for uint256;
    using SignedSafeMath for int256;
    
    /* ========== STATE VARIABLES ========== */

    // ========== FLAGS
    bool public migrated = false;

    // ========== CORE
    address public fund;
    address public cash;

    address public boardroomTimeLock;
    uint256 public boardroomTimeLockProportion = 70;
    
    address public boardroom;
    uint256 public boardroomProportion = 30;

    address public seigniorageOracle;

    // ========== PARAMS
    uint256 public cashPriceOne =  10**18;
    uint256 private accumulatedSeigniorage = 0;
    uint256 public fundAllocationRate = 10;
    uint256 public IssuanceRatio = 80;
    uint256 public treasuryReserveRatio = 20;

    uint256 public timePeriod = 12 hours;
    int256 public inflationDeflationAmount = 0;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _cash,
        address _seigniorageOracle,
        address _boardroomTimeLock,
        address _boardroom,
        address _fund,
        uint256 _startTime
    ) public Epoch(10 minutes, _startTime, 0) {
        cash = _cash;
        seigniorageOracle = _seigniorageOracle;
        boardroomTimeLock = _boardroomTimeLock;
        boardroom = _boardroom;
        fund = _fund;
    }

    /* =================== Modifier =================== */

    modifier checkMigration {
        require(!migrated, 'Treasury: migrated');

        _;
    }

    modifier checkOperator {
        require(
            IBasisAsset(cash).operator() == address(this) &&
                Operator(boardroomTimeLock).operator() == address(this) &&
                Operator(boardroom).operator() == address(this),
            'Treasury: need more permission'
        );

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */
    // budget
    function getReserve() public view returns (uint256) {
        return accumulatedSeigniorage;
    }

    // oracle
    function getSeigniorageOraclePrice() public view returns (uint256) {
        return _getCashPrice(seigniorageOracle);
    }

    function _getCashPrice(address oracle) internal view returns (uint256) {
        try IOracle(oracle).consult(cash, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert('Treasury: failed to consult cash price from the oracle');
        }
    }

    /* ========== GOVERNANCE ========== */

    function migrate(address target) public onlyOperator checkOperator {
        require(!migrated, 'Treasury: migrated');
        // cash
        IERC20(cash).safeTransfer(target, IERC20(cash).balanceOf(address(this)));

        migrated = true;
        emit Migration(target);
    }

    function setFund(address newFund) public onlyOperator {
        fund = newFund;
        emit ContributionPoolChanged(msg.sender, newFund);
    }

    function setFundAllocationRate(uint256 rate) public onlyOperator {
        fundAllocationRate = rate;
        emit ContributionPoolRateChanged(msg.sender, rate);
    }
    
    function setIssuanceRatio(uint256 ratio) public onlyOperator {
        IssuanceRatio = ratio;
    }
    
    function setTimePeriod(uint256 time) public onlyOperator {
        timePeriod = time;
    }

    /* ========== MUTABLE FUNCTIONS ========== */
    function _updateCashPrice() internal {
        try IOracle(seigniorageOracle).update()  {} catch {}
    }
    
    function allocateSeigniorage()
        external
        onlyOneBlock
        checkMigration
        checkStartTime
        checkEpoch
        checkOperator
    {
        // --BIP 1 Supply
        _updateCashPrice();
        uint256 cashPrice = _getCashPrice(seigniorageOracle);
        if (cashPrice == cashPriceOne || cashPrice == 0) {
            inflationDeflationAmount = 0;
            return;
        }
        
        // circulating supply
        inflationDeflationAmount = computeSupplyDelta(cashPrice,cashPriceOne);
        
        // Price is less than 1 deflation
        if (cashPrice < cashPriceOne) {
                IBasisAsset(cash).rebase(epoch,inflationDeflationAmount);
                externalCall();
                IBoardroom(boardroomTimeLock).burnReward();
                IBoardroom(boardroom).burnReward();
            return; // just advance epoch instead revert
        }

        IBoardroom(boardroomTimeLock).setTimeLock(block.timestamp.add(timePeriod));
        uint256 seigniorage = uint256(inflationDeflationAmount).mul(IssuanceRatio).div(100);  // IssuanceRatio = 50

        // --BIP 2 Fund
        uint256 fundReserve = seigniorage.mul(fundAllocationRate).div(100);  // fundAllocationRate = 10
        if (fundReserve > 0) {
            IRewardsToken(cash).mint(address(this), fundReserve);
            IERC20(cash).safeApprove(fund, fundReserve);
            ISimpleERCFund(fund).deposit(
                cash,
                fundReserve,
                "Treasury: Seigniorage Allocation"
            );
            emit ContributionPoolFunded(now, fundReserve);
        }
        seigniorage = seigniorage.sub(fundReserve);    // fundAllocationRate out = 90
        
        // --BIP 3 Boardroom
        if (seigniorage > 0) {
            IRewardsToken(cash).mint(address(this), seigniorage);
            // boardroomTimeLock
            uint256 boardroomTimeSeigniorage = seigniorage.mul(boardroomTimeLockProportion).div(100); // boardroomTimeLockProportion = 70
            IERC20(cash).safeApprove(boardroomTimeLock, boardroomTimeSeigniorage);
            IBoardroom(boardroomTimeLock).allocateSeigniorage(boardroomTimeSeigniorage);
            // boardroom
            uint256 boardroomSeigniorage = seigniorage.mul(boardroomProportion).div(100); // boardroomProportion = 30
            IERC20(cash).safeApprove(boardroom, boardroomSeigniorage);
            IBoardroom(boardroom).allocateSeigniorage(boardroomSeigniorage);
            emit BoardroomFunded(now, seigniorage);
        }
    }
    
    /**
     * @return Computes the total supply adjustment in response to the exchange rate
     *         and the targetRate.
     */
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        public view returns (int256)
    {
        int256 targetRateSigned = targetRate.toInt256Safe();
        int256 supply = (IERC20(cash).totalSupply()
                        .sub(IERC20(cash).balanceOf(address(this)))
                        .sub(IERC20(cash).balanceOf(cash))).toInt256Safe();
        if(rate < targetRate) {
            supply = IERC20(cash).totalSupply().toInt256Safe();
        }
        return supply.mul(rate.toInt256Safe().sub(targetRateSigned)).
                    div(targetRateSigned);
    }

    function setBoardroomProportion(uint256 _boardroomTimeLockProp,uint256 _boardroomProp) external onlyOperator {
        boardroomTimeLockProportion = _boardroomTimeLockProp;
        boardroomProportion = _boardroomProp;
    }
    // GOV  
    event Migration(address indexed target);
    event ContributionPoolChanged(address indexed operator, address newFund);
    event ContributionPoolRateChanged(
        address indexed operator,
        uint256 newRate
    );

    // CORE
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event BoardroomFunded(uint256 timestamp, uint256 seigniorage);
    event ContributionPoolFunded(uint256 timestamp, uint256 seigniorage);
}