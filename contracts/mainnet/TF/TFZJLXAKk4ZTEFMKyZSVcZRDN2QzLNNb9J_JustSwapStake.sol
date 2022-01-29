//SourceUnit: IERC20.sol

pragma solidity ^0.5.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function mint(address _to, uint amount) external;
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: IPenguStake.sol

pragma solidity ^0.5.4;

/**
 * @dev Interface of the Pengu Staking platform
 */
interface IPenguStake {
  function claimPending(address recipient, uint256 amount) external;
  function getPenguPerSecond() external returns (uint);
}


//SourceUnit: JustSwapStake.sol

pragma solidity ^0.5.4;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./IPenguStake.sol";

contract JustSwapStake {
  using SafeMath for uint256;

  address payable public devaddr;
  address public contractAddress;

  IPenguStake public link;

  IERC20 private token;

  uint private penguPerSecond;

  uint32 public currentPoolShare;

  mapping (address => uint) private startTime;

  constructor(address _token, address _contractAddress) public {
    token = IERC20(_token);
    link = IPenguStake(_contractAddress);
    contractAddress = _contractAddress;
    devaddr = msg.sender;
  }

  event Deposit(address from, string token, uint amount);
  event Withdraw(address from, string token, uint amount);

  //Claims the pending rewards
  function claimPending(address _from) public onlyContract {
    calculateHashRate();
    link.claimPending(_from, pendingRewards(_from)); //Try it again
    startTime[_from] = now;
  }

  function pendingRewards(address _from) public view returns (uint) {
    uint stakedDuration = now.sub(startTime[_from]);//~ Block Time
    return penguPerSecond.mul(getTokenShare(_from)).mul(stakedDuration).div(currentPoolShare).div(10000);
  }

  //Get's the users
  function getTokenShare(address _from) public view returns (uint) {
    uint bal = token.balanceOf(_from);
    if(bal != 0) {
      return bal.mul(10000).div(token.totalSupply()); //Percentage 100.00 would be 10000
    }
    return 0;
  }

  function setTokenLinkAddress(address _contractAddress) public onlyOwner {
    link = IPenguStake(_contractAddress);
    contractAddress = _contractAddress;
  }

  function setPoolShare(uint32 _newShare) public onlyOwner {
    currentPoolShare = _newShare;
  }

  function calculateHashRate() internal {
    penguPerSecond = link.getPenguPerSecond();
  }

  modifier onlyOwner {
    require(msg.sender == devaddr);
    _;
  }
  modifier onlyContract {
    require(msg.sender == devaddr || msg.sender == contractAddress);
    _;
  }

}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.4;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}