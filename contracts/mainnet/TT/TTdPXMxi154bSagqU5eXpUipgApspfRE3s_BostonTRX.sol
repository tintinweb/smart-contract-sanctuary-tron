//SourceUnit: boston.sol

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

contract BostonTRX is Ownable {   
    
    uint public MIN_DEPOSIT_TRX = 1 ;
    uint public DEPOSIT_FEES = 6;
    uint public WITHDRAW_FEES = 10;
    address contractAddress = address(this);
    
    struct Investor {
        bool registered;
        uint invested;
       
    }

    mapping (address => Investor) public investors;

    uint public totalInvested;
    address public contractAddr = address(this);
    constructor() {
        
    }
    using SafeMath for uint256;       
    event TokenAddressChaged(address tokenChangedAddress);    
    event DepositAt(address user, uint tariff, uint amount);    
    
    function transferOwnership(address _to) public {
        require(msg.sender == owner, "Only owner");
        address oldOwner  = owner;
        owner = _to;
        emit OwnershipTransferred(oldOwner,_to);
    }
    
    // Set buy price decimal i.e. 
    function setMinTRX(uint _trxAmt) public {
      require(msg.sender == owner, "Only owner");
      MIN_DEPOSIT_TRX = _trxAmt;
    }
    
    function setDepositFees(uint _fees) public {
      require(msg.sender == owner, "Only owner");
      DEPOSIT_FEES = _fees;
    }
    
    function setWithdrawalFees(uint _fees) public {
      require(msg.sender == owner, "Only owner");
      WITHDRAW_FEES = _fees;
    }

    function depositTRX() external payable {
        uint tariff = 0;
        uint fees= DEPOSIT_FEES;
        require(msg.value >= 0);
       
        uint tokenVal = msg.value;
        
        uint depositFees = tokenVal*fees/100;
        tokenVal = tokenVal-depositFees;
        payable(owner).transfer(depositFees);
        
        
        investors[msg.sender].invested += tokenVal;
        totalInvested += tokenVal;
        
        emit DepositAt(msg.sender, tariff, tokenVal);
    } 
  
    function withdrawalTRX(address payable _to, uint _amount, uint _type) external{
        require(msg.sender == owner, "Only owner");
        require(_amount != 0, "Zero amount error");
        uint fees= WITHDRAW_FEES;
        uint withFees = _amount*fees/100;
        _amount = _amount-withFees;
        if(_type==1){
            _amount = _amount/2;    
        }
        payable(owner).transfer(withFees);
        _to.transfer(_amount);
    }
}