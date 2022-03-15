//SourceUnit: TruswapFinance.sol

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

/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

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

contract TruswapFinance is Ownable {    
    using SafeMath for uint256;  
    address tokenAddr;
    address contractAddr = address(this);
    event DepositAt(address user, uint amount, uint time, uint plan);
    event withdrawalAt(address user, uint amount, uint time);
    // Constructors
    constructor (address _tokenAddr) {
        tokenAddr = _tokenAddr;
    }
    
    function deposit(uint plan,uint amount) external{
        require(plan<7);
        require(amount >= 1000000,"Minimum deposit 1 Token");
        TRC20 token = TRC20(tokenAddr);
        require(token.balanceOf(msg.sender) >= amount,"Insufficient Amount");
        require(token.allowance(msg.sender,contractAddr) >= amount, "Insufficient Permission");
        token.transferFrom(msg.sender, contractAddr, amount);       
        emit DepositAt(msg.sender, amount,block.timestamp,plan);
    }
    
    function withdrawalToAddress(address to, uint amount) external{
        require(msg.sender == owner);
        TRC20 token = TRC20(tokenAddr);
        require(token.balanceOf(contractAddr) >= amount,"Insufficient Contract Balance");
        token.transfer(to,amount);
        emit withdrawalAt(to, amount,block.timestamp);
    }
    
    
    function transferOwnership(address to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = to;
        emit OwnershipTransferred(oldOwner,to);
    }
}