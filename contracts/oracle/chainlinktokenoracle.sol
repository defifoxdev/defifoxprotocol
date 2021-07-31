// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelinUpgrade/contracts/access/OwnableUpgradeable.sol";

import "../interfaces/ITokenOracle.sol";

contract TokenOracle is OwnableUpgradeable, ITokenOracle {

    mapping(address => address) public priceFeeds;

    event SetPriceFeed(address _token, address _feed, address _newfeed);

    constructor() public {
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function setFeed(address _token, address _feed) public onlyOwner {
        emit SetPriceFeed(_token, priceFeeds[_token], _feed);
        priceFeeds[_token] = _feed;
    }

    function setFeeds(address[] memory _token, address[] memory _feed) external onlyOwner {
        require(_token.length == _feed.length, 'length error');
        for(uint256 i = 0; i < _token.length; i ++) {
            setFeed(_token[i], _feed[i]);
        }
    }

    function getPrice(address _token) external override view returns (int) {
        address theFeed = priceFeeds[_token];
        if(theFeed == address(0)) return 0;

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorV3Interface(theFeed).latestRoundData();
        return price;
    }
}