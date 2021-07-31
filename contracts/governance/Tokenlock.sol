// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/token/ERC20/IERC20.sol";
import "@openzeppelinBase/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelinBase/contracts/math/SafeMath.sol";

import '../DFOXToken.sol';

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 */

contract Tokenlock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable rewardToken;
    address public immutable toAddress;

    uint256 public immutable beginTime;
    uint256 public immutable totalAmount;
    uint256 public immutable drawCount;
    uint256 public drawAmount;
    uint256 public constant releaseInterval = (1 weeks);

    constructor (
            address _rewardToken, address _toAddress,
            uint256 _beginTime, uint256 _drawCount,
            uint256 _totalAmount) public {
        require(IERC20(_rewardToken).totalSupply() >= 0, 'token error');
        require(_beginTime >= block.timestamp, 'begintime error');
        rewardToken = _rewardToken;
        toAddress = _toAddress;
        beginTime = _beginTime;
        drawCount = _drawCount;
        totalAmount = _totalAmount;
    }

    function quota() public view returns (uint256) {
        if(beginTime > block.timestamp) {
            return 0;
        }
        uint256 daypass = block.timestamp.sub(beginTime).div(releaseInterval).add(1);
        if(daypass > drawCount) {
            daypass = drawCount;
        }
        return totalAmount.mul(daypass).div(drawCount).sub(drawAmount);
    }

    function unlock() external returns (uint256) {
        uint256 value = quota();
        if(value > 0) {
            DFOXToken(rewardToken).mint(toAddress, value);
            drawAmount = drawAmount.add(value);
        }
    }
}