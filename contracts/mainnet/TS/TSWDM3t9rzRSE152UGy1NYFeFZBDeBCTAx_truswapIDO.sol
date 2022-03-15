//SourceUnit: truswapIDO.sol

// SPDX-License-Identifier: none
pragma solidity ^0.8.0;

interface TRC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract truswapIDO{
    
  uint public priceTRX = 60; // 0.079 usd
  uint public decimalTRXPrice = 1000;
 
  
  struct Investor {
    bool registered;
    uint invested;
  }

  address public buyTokenAddr;
  address public receiveTokenAddr;
  address public updater;
  address public contractAddr = address(this);
  uint public currentTokenPrice = 3;
  uint public currrentTokenPriceDecimal = 1000;

  address public owner = msg.sender;
  
  uint[] public refRewards;
  
  mapping (address => Investor) public investors;
  event buyAt(address user, uint amount);
  event sellAt(address user, uint amount);
  event Withdraw(address user, uint amount);
  event OwnershipTransferred(address);
  
  constructor(address _sendTokenAddr) {
        updater = msg.sender;
        buyTokenAddr = _sendTokenAddr;
      
  }

  
  function buy() external payable {

    require(msg.value >= 0,"Invalid Amount");
    TRC20 token = TRC20(buyTokenAddr);
    address sender = msg.sender;
    uint256 contractTokenBalance = token.balanceOf(address(this));
    
    uint tokenVal = (msg.value * priceTRX*currrentTokenPriceDecimal) / (decimalTRXPrice*currentTokenPrice);
    require(tokenVal <= contractTokenBalance, "Not enough tokens in the reserve");
   
    token.transfer(msg.sender, tokenVal);
    emit buyAt(sender, tokenVal);
   } 
   
   function sell(uint tokenVal, address payable sender) external {

    require(tokenVal >= 0,"Invalid Amount");
    require(sender==msg.sender,"Invalid Account");
    TRC20 token = TRC20(buyTokenAddr);
   
    uint tronAmount = (tokenVal*currentTokenPrice*decimalTRXPrice)/(priceTRX*currrentTokenPriceDecimal);
    
    require(token.balanceOf(sender) >= tokenVal,"Insufficient Amount");
    require(token.allowance(sender,contractAddr) >= tokenVal, "Insufficient Permission");
    token.transferFrom(sender, contractAddr, tokenVal);       
    
    sender.transfer(tronAmount);
    emit sellAt(sender, tokenVal);
   } 


  

    /*
    like tokenPrice = 0.001
    setBuyPrice = 1 
    tokenPriceDecimal= 1000
    */
    // Set buy price  

    function changTokenPrice(uint _currentTokenPrice, uint _currrentTokenPriceDecimal) external {
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        currentTokenPrice   = _currentTokenPrice;
        currrentTokenPriceDecimal     = _currrentTokenPriceDecimal;
    }


    function setBuyTokenAddr(address _buyTokenAddr) external {
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        buyTokenAddr = _buyTokenAddr;
    }
    
    function setReceiveTokenAddr(address _receiveTokenAddr) external {
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        receiveTokenAddr = _receiveTokenAddr;
    }




    // only by owner
    function changeUpdater(address _updater) external {
        require(msg.sender == owner, "Only owner");
        updater = _updater;
    }

    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        TRC20 _token = TRC20(tokenAddress);
        _token.transfer(to, amount);
    }
    
    // Owner TRX Withdraw
    // Only owner can withdraw TRX from contract
    function withdrawTRX(address payable to, uint amount) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) external {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
    }

    // TRX Price Update
    // Only owner can call this function
     /*
    like trxPrice = 0.001
    _priceTRX = 1 
    _decimalTRXPrice= 1000
    */
    function trxpriceChange(uint _priceTRX,uint _decimalTRXPrice) external {
        require(msg.sender == owner, "Only owner");
        priceTRX = _priceTRX;
        decimalTRXPrice = _decimalTRXPrice;
    }



    function buyCalculator(uint amount) public view returns (uint) {
        
        uint tokenVal = (amount * priceTRX*currrentTokenPriceDecimal) / (decimalTRXPrice*currentTokenPrice);
        
        return tokenVal;
    }
    
    function sellCalculator(uint tokenVal) public view returns (uint) {
        
        uint tronAmount = (tokenVal*currentTokenPrice*decimalTRXPrice)/(priceTRX*currrentTokenPriceDecimal);
        
        return tronAmount;
    }


}