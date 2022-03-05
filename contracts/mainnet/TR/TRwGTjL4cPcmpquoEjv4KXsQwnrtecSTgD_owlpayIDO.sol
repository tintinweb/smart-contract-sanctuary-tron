//SourceUnit: owlpay_ido_live.sol

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

contract owlpayIDO{
    
  uint public priceTRX = 59; // 0.079 usd
  uint public decimalTRXPrice = 1000;
 
  
  struct Investor {
    bool registered;
    uint invested;
  }

  address public buyTokenAddr;
  address public receiveTokenAddr;
  address public updater;
  address public contractAddr = address(this);
  uint public currentTokenPrice = 2;
  uint public currrentTokenPriceDecimal = 100;

  address public owner = msg.sender;
  
  uint[] public refRewards;
  
  mapping (address => Investor) public investors;
  event DepositAt(address user, uint amount);
  event Withdraw(address user, uint amount);
  event OwnershipTransferred(address);
  
  constructor(address _sendTokenAddr,address _receiveTokenAddr) {
        updater = msg.sender;
        buyTokenAddr = _sendTokenAddr;
        receiveTokenAddr = _receiveTokenAddr;
  }

  
  function buyTokenWithTRX() external payable {

    require(msg.value >= 0,"Invalid Amount");
    TRC20 token = TRC20(buyTokenAddr);
    address sender = msg.sender;
   
    uint tokenVal = (msg.value * priceTRX / (decimalTRXPrice/currrentTokenPriceDecimal)) / currentTokenPrice;
    
    investors[sender].invested += tokenVal;
    
    token.transfer(msg.sender, tokenVal);
    emit DepositAt(sender, tokenVal);
   } 
   
   
    function buyTokenWithUSDT(uint amount) external {
            require(amount >= 1000000, "Minimum limit is 1");
            TRC20 sendtoken    = TRC20(buyTokenAddr);
            TRC20 receiveToken = TRC20(receiveTokenAddr); //Mainnet
            
            uint tokenVal = (amount* currrentTokenPriceDecimal) / currentTokenPrice ; 
            receiveToken.transferFrom(msg.sender, contractAddr, amount);
            
            investors[msg.sender].invested += tokenVal;
            
            sendtoken.transfer(msg.sender, tokenVal);
            
            emit DepositAt(msg.sender, tokenVal);
  
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



    function tokenInTRX(uint amount) public view returns (uint) {
        
        uint tokenVal = (amount * priceTRX*decimalTRXPrice *currrentTokenPriceDecimal) / (decimalTRXPrice*currentTokenPrice);
        
        return tokenVal;
    }


}