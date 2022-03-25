//SourceUnit: ucf_contract.sol

// SPDX-License-Identifier: none
pragma solidity ^0.8.6;
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
contract UniversalCryptoFund is Ownable {   
    address public tokenAddr; 
    uint public buyPrice        = 2;
    uint public buyPriceDecimal = 1000;
    address _contract = address(this);
    constructor(address tokenaddr) {
        tokenAddr = tokenaddr;        
    }
    using SafeMath for uint256;       
    event DepositAt(address user, uint tariff, uint amount);  

    function despositToken(uint _tariff, uint _amount) external {
        TRC20 token    = TRC20(tokenAddr);
        address sender = msg.sender;
        uint amount    = _amount * 10**6;
        uint tokens    = amount / buyPrice * buyPriceDecimal;
        token.transferFrom(sender, _contract, tokens);
        emit DepositAt(msg.sender, _tariff, tokens);
    }

    function depositTRX() external payable {    
        emit DepositAt(msg.sender, 0, msg.value);
    }

    function withdrawalToAddress(address payable _to, address _tokenAddr, uint _amount) external{
        require(msg.sender == owner, "Only owner");
        TRC20 _tokenwith = TRC20(_tokenAddr);
        require(_amount != 0, "Zero withdrawal");
        _tokenwith.transfer(_to, _amount);
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