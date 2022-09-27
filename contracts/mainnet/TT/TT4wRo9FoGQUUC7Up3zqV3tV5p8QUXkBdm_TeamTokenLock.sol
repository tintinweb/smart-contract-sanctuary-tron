//SourceUnit: TeamTokenLock.sol

pragma solidity ^0.5.0;

/* pragma experimental ABIEncoderV2; */


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
}

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}

contract IERC20 {
  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract TeamTokenLock {

    using SafeMath for uint256;

    /***********************************|
    |       Events And Variables        |
    |__________________________________*/

    // Receiver withdraw token
    event WithDrawToken(address _to, uint256 amount);
    // Receiver withdraw all token after endtime
    event WithdrawAllTokens(address _to, uint256 _amount);
    // Record whether token withdraw event happens in a month
    // User cannot withdraw token twice in the same month
    mapping(uint=>bool) lockedMonthWithdraw;
    // After 4 month, token starts to release
    uint public startLockMonth = 4;

    // Mainnet DZI Token
    // TLi2o9XadMAonBJvzoj1kHBkNe6Nh1SaZ3
    IERC20 public token;

    // Contract creator :)
    address public owner;
    
    // Mainnet
    // TAcjZfCBZSzWeB5ox47uoi6te4WyLyuRzT
    // Token Receiver
    address public receiver;
    
    // Let's say One Month has 30 days. :)
    uint public oneMonth = 30 * 24 * 60 * 60;

    // UTC Time 
    uint public startLockTime;

    modifier onlyReceiver {
      require(msg.sender == receiver);
      _;
    }

    // Contract creator can help receiver withdraw token
    modifier onlyReceiverAndOwner {
      require(msg.sender == receiver || msg.sender == owner);
      _;
    }

    /***********************************|
    |         Functions                 |
    |__________________________________*/
    
    constructor(address _token, address _receiver) public {
        token = IERC20(_token);
        receiver = _receiver;
        owner = msg.sender;
        // Token is issued 11 days ago
        uint deltaTime = 11 days;
        startLockTime = now - deltaTime;
    }

    /**
     * @dev Calc how much token receiver can get
     */
    function getAvailableToken() public view returns(uint256) {
      uint256 available_token = token.balanceOf(address(this));
      uint lockedMonth = getLockedMonth();
      if (lockedMonth == 0) {
          return 0;
      }
      if (lockedMonthWithdraw[lockedMonth]) {
          return 0;
      }
      if (lockedMonth <= 12) {
        available_token = available_token.div(12 - lockedMonth + 1);
      }
      return available_token;
    }

    /**
     * @dev Receiver get all available token at this month
     */
    function withdrawAvailableToken() onlyReceiverAndOwner public {
      uint256 availableToken = getAvailableToken();
      require(availableToken > 0, "Available balance is 0!");
      require(lockedMonthWithdraw[getLockedMonth()] == false);
      lockedMonthWithdraw[getLockedMonth()] = true;
      token.transfer(receiver, availableToken);
      emit WithDrawToken(receiver, availableToken);
    }
    
    // Receiver can withdraw all token after 1 year without any limit.
    function withdrawAllTokensAfterOneYear() onlyReceiverAndOwner public {
       require(getLockedMonth() >= 12 + startLockMonth);
       uint256 restToken = token.balanceOf(address(this));
       token.transfer(receiver, restToken);
       emit WithdrawAllTokens(receiver, restToken);
    }

    function getTotalLockedMonth() public view returns(uint){
        uint ret = (now - startLockTime) / oneMonth;
        return ret;
    }

    function getLockedMonth() private view returns(uint){
        require(now >= startLockTime);
        uint ret = getTotalLockedMonth();
        if (ret >= startLockMonth - 1) {
            return ret - startLockMonth + 1;    
        } else {
            return 0;
        }
    }
    
    // Total amount of Locked Token 
    function getTotalLockedToken() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function () external payable {
        require(msg.value == 0);
    }   
}