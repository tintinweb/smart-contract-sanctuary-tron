//SourceUnit: rapid.sol

// SPDX-License-Identifier: none
pragma solidity ^0.8.6;


contract Ownable {
  address public owner;  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract Rapidnetwork is Ownable {   
    address public tokenAddr; 
    uint public buyPrice        = 1;
    uint public buyPriceDecimal = 1;
   
    
       
    event DepositAt(address user, uint tariff, uint amount);  


    function depositTRX() external payable {    
        emit DepositAt(msg.sender, 0, msg.value);
    }

    

    function withdrawalTrx(address payable to, uint amount) external{
        require(msg.sender == owner);
        to.transfer(amount);
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }

    // Upto _price_decimal decimals
    function setTokenPrice(uint _price,uint _price_decimal) external {
        require(msg.sender == owner, "Only owner");
        buyPrice = _price;
        buyPriceDecimal = _price_decimal;
    }
    
    function setTokenAddr(address tokenAddress) public {  
        require(msg.sender == owner, "Only owner");
        tokenAddr = tokenAddress;
    }
}