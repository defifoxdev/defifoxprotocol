// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelinUpgrade/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelinUpgrade/contracts/math/SignedSafeMathUpgradeable.sol";
import "@openzeppelinUpgrade/contracts/math/SafeMathUpgradeable.sol";
import "@openzeppelinUpgrade/contracts/access/OwnableUpgradeable.sol";

import "../../interfaces/uniswapv2/IUniswapV2Pair.sol";

import "../interfaces/ITokenOracle.sol";
import "../interfaces/IPriceChecker.sol";

contract PriceCheckerLPToken is OwnableUpgradeable, IPriceChecker {
    using SafeMathUpgradeable for uint256;
    using SignedSafeMathUpgradeable for int256;

    mapping(address => uint256) public priceSlippage;
    ITokenOracle public tokenOracle;
    uint256 public largeSlipRate;

    event SetPriceSlippage(address _lptoken, uint256 _oldv, uint256 _newv);
    event SetLargeSlipRate(uint256 _oldv, uint256 _newv);
    event SetTokenOracle(address _oldv, address _newv);

    constructor() public {
    }

    function initialize(address _tokenOracle) public initializer {
        __Ownable_init();
        largeSlipRate = 4e9;
        setTokenOracle(_tokenOracle);
    }

    function setLargeSlipRate(uint256 _largeSlipRate) external onlyOwner {
        require(_largeSlipRate >= 1e9, 'value error');
        emit SetLargeSlipRate(largeSlipRate, _largeSlipRate);
        largeSlipRate = _largeSlipRate;
    }

    function setPriceSlippage(address _lptoken, uint256 _slippage) external onlyOwner {
        require(_slippage >= 0 && _slippage <= 1e9, 'value error');
        emit SetPriceSlippage(_lptoken, priceSlippage[_lptoken], _slippage);
        priceSlippage[_lptoken] = _slippage;
    }
    
    function setTokenOracle(address _tokenOracle) public onlyOwner {
        emit SetTokenOracle(address(tokenOracle), _tokenOracle);
        tokenOracle = ITokenOracle(_tokenOracle);
    }

    function getPriceSlippage(address _lptoken) public override view returns (uint256) {
        if(priceSlippage[_lptoken] > 0) {
            return priceSlippage[_lptoken]; 
        }
        return uint256(1e7);
    }

    function getLPTokenPriceInMdex(address _lptoken, address _t0, address _t1) public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(_lptoken);
        (uint256 r0, uint256 r1, ) = pair.getReserves();
        uint256 d0 = ERC20Upgradeable(_t0).decimals();
        uint256 d1 = ERC20Upgradeable(_t1).decimals();
        if(d0 != 18) {
            r0 = r0.mul(1e18).div(10**d0);
        }
        if(d1 != 18) {
            r1 = r1.mul(1e18).div(10**d1);
        }
        return r0.mul(1e18).div(r1);
    }


    function getLPTokenPriceInOracle(address _t0, address _t1) public view returns (uint256) {
        int256 price0 = tokenOracle.getPrice(_t0);
        int256 price1 = tokenOracle.getPrice(_t1);
        if(price0 <= 0 || price1 <= 0) {
            return 0;
        }
        int256 priceInOracle = price1.mul(1e18).div(price0);
        if(priceInOracle <= 0) {
            return 0;
        }
        return uint256(priceInOracle);
    }

    function checkLPTokenPriceLimit(address _lptoken, bool _largeType) external override view returns (bool) {
        IUniswapV2Pair pair = IUniswapV2Pair(_lptoken);
        address t0 = pair.token0();
        address t1 = pair.token1();
        uint256 price0 = getLPTokenPriceInMdex(_lptoken, t0, t1);
        uint256 price1 = getLPTokenPriceInOracle(t0, t1);
        if(price0 == 0 || price1 == 0) {
            return false;
        }
        uint256 slip = getPriceSlippage(_lptoken);
        uint256 priceRate = price0.mul(1e9).div(price1);
        if(_largeType) {
            slip = slip.mul(largeSlipRate).div(1e9);
        }
        if(priceRate >= uint256(1e9).add(slip) || priceRate <= uint256(1e9).sub(slip)) {
            return false;
        }
        return true;
    }
}