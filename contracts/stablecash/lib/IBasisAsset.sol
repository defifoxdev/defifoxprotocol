// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelinBase/contracts/token/ERC20/IERC20.sol";

interface IBasisAsset {
    function mint(address recipient, uint256 amount) external returns (bool);
    
    function rebase(uint256 epoch, int256 supplyDelta) external returns(uint256);
    
    function burn(uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function isOperator() external returns (bool);

    function operator() external view returns (address);
}