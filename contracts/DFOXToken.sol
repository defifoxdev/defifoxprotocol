// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelinBase/contracts/access/Ownable.sol";
import "@openzeppelinBase/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelinBase/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IRewardsToken.sol";

contract DFOXToken is ERC20Capped, Ownable, IRewardsToken {
    constructor (
            string memory _name,
            string memory _symbol,
            uint256 _totalSupply
        ) public ERC20Capped(_totalSupply) ERC20(_name, _symbol) {
    }

    mapping(address => bool) public mintWhitelist;

    function setMintWhitelist(address _account, bool _enabled) external override onlyOwner {
        mintWhitelist[_account] = _enabled;
    }

    function checkWhitelist(address _account) external override view returns (bool) {
        return mintWhitelist[_account];
    }

    function mint(address _account, uint256 _amount) external override {
        require(mintWhitelist[msg.sender], 'not allow');
        _mint(_account, _amount);
    }

    function burn(uint256 _amount) external override onlyOwner {
        _burn(msg.sender, _amount);
    }
}

