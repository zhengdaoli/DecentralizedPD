// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.2 <0.8.0;
// pragma experimental ABIEncoderV2;

pragma solidity ^0.6.10;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


contract PCoinBank is ERC20 {
    
    uint8 public constant pc_decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 88888888 * (10 ** uint256(pc_decimals));
    
    address creater;
    
    constructor() public ERC20("Pcoin", "PC") {
        _mint(msg.sender, INITIAL_SUPPLY);
        creater = msg.sender;
        approve(msg.sender, INITIAL_SUPPLY);
    }
    
    function getCreater() public view returns (address){
        return creater;
    }
}
