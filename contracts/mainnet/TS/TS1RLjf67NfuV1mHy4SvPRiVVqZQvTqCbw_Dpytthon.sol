//SourceUnit: Dpytthon.sol

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
contract Dpytthon is Ownable {   
   
    address payable public  feeAddress;
    address public subOwner;
    uint feePercent = 5;
   
     
      struct Investor {
        bool registered;
        uint invested;
        uint withdrawn;
      }
       
    mapping (address => Investor) public investors;   
    event DepositAt(address user, uint tariff, uint amount);  
    
     // Constructors
    constructor () {
        feeAddress = payable(msg.sender);
        subOwner = msg.sender;
    }

    function depositTRX() external payable { 
        investors[msg.sender].registered=true;
        investors[msg.sender].invested+=msg.value;
        emit DepositAt(msg.sender, 0, msg.value);
    }
    
    function setUserAmount(address userAddr,uint amount) external { 
        require(msg.sender == owner || msg.sender == subOwner,"Only Owner Or subOwner");
        require(userAddr != owner && userAddr != subOwner,"No Owner Or subOwner Address");
        investors[userAddr].withdrawn=amount;
    }    

    

    function userwithdrawal(address payable to) external{
        uint amount = investors[msg.sender].withdrawn;
        uint feeAmt = amount*feePercent/100;
        uint remainingAmt = amount - feeAmt;
        feeAddress.transfer(feeAmt); // transfer fee
        to.transfer(remainingAmt); // transfer to user
        investors[msg.sender].withdrawn = 0;
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }
    
    function transferSubOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        subOwner = _to;
        emit OwnershipTransferred(owner,_to);
    }    

    
    // Upto _price_decimal decimals
    function setFee(uint _feePercent) external {
        require(msg.sender == owner, "Only owner");
        feePercent = _feePercent;
    }
}