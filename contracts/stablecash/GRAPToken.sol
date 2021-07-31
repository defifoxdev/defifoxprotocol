// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/access/Ownable.sol";
import "@openzeppelinBase/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelinBase/contracts/token/ERC20/ERC20.sol";

import "./lib/Operator.sol";

import "../interfaces/IRewardsToken.sol";

import "./GRAPTokenERC20.sol";

contract GRAPToken is GRAPTokenERC20, Ownable, Operator, IRewardsToken {
    using SafeMath for uint256;

    mapping(address => bool) public mintWhitelist;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    constructor () 
        public GRAPTokenERC20('GRAP STABLE Coin', 'GRAP') {
    }

    modifier onlyWhitelist() {
        require(
            mintWhitelist[msg.sender],
            "operator: caller is not the onlyWhitelist"
        );
        _;
    }

    function setMintWhitelist(address _account, bool _enabled) external override onlyOwner {
        mintWhitelist[_account] = _enabled;
    }

    function checkWhitelist(address _account) external override view returns (bool) {
        return mintWhitelist[_account];
    }

    function mint(address _account, uint256 _amount) external override onlyWhitelist {
        _transfer(address(this), _account, _amount);
    }

    function burn(uint256 _amount) external override onlyWhitelist {
        _transfer(msg.sender, address(this), _amount);
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        public 
        onlyOperator
        returns(uint256)
    {
        uint256 total = _rebase(supplyDelta);
        emit LogRebase(epoch, total);
        return total;
    }
}

