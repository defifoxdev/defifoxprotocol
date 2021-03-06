// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelinBase/contracts/math/SafeMath.sol";

import "./lib/Operator.sol";
import "./lib/Math.sol";

import "./lib/IBasisAsset.sol";
import "./lib/IOracle.sol";

contract Epoch is Operator {
    using SafeMath for uint256;

    uint256 private period;
    uint256 private startTime;
    uint256 private lastExecutedAt;
    uint256 public epoch = 0;
    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _period,
        uint256 _startTime,
        uint256 _startEpoch
    ) public {
        require(_startTime > block.timestamp, "Epoch: invalid start time");
        period = _period; 
        startTime = _startTime; 
        lastExecutedAt = startTime.add(_startEpoch.mul(period)); 
    }

    /* ========== Modifier ========== */

    modifier checkStartTime {
        require(now >= startTime, "Epoch: not started yet");

        _;
    }

    modifier checkEpoch {
        require(now > startTime, "Epoch: not started yet");
        require(getCurrentEpoch() >= getNextEpoch(), "Epoch: not allowed");

        _;
        epoch = epoch.add(1);
        lastExecutedAt = block.timestamp;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getLastEpoch() public view returns (uint256) {
        return lastExecutedAt.sub(startTime).div(period);
    }

    function getCurrentEpoch() public view returns (uint256) {
        return Math.max(startTime, block.timestamp).sub(startTime).div(period);
    }

    function getNextEpoch() public view returns (uint256) {
        if (startTime == lastExecutedAt) { 
            return getLastEpoch(); 
        }
        return getLastEpoch().add(1); 
    }

    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(getNextEpoch().mul(period));
    }


    function getPeriod() public view returns (uint256) {
        return period;
    }

    function getStartTime() public view returns (uint256) {
        return startTime;
    }

    /* ========== GOVERNANCE ========== */

    function setPeriod(uint256 _period) external onlyOperator {
        period = _period;
    }
}
