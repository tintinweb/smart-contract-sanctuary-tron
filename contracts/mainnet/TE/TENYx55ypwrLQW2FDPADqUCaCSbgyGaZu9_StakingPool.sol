//SourceUnit: lp.sol

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

library Math {
  /**
   * @dev Returns the largest of two numbers.
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  /**
   * @dev Returns the smallest of two numbers.
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  /**
   * @dev Returns the average of two numbers. The result is rounded towards
   * zero.
   */
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    // (a + b) / 2 can overflow, so we distribute
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
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
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
   *
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
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
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
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IERC20 {
  function decimals() external view returns (uint256);
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies in extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {size := extcodesize(account)}
    return size > 0;
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success,) = recipient.call{value : amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain`call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  /**
   * @dev Deprecated. This function has issues similar to the ones found in
   * {IERC20-approve}, and its usage is discouraged.
   *
   * Whenever possible, use {safeIncreaseAllowance} and
   * {safeDecreaseAllowance} instead.
   */
  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    // solhint-disable-next-line max-line-length
    require((value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   */
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {// Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

interface IJustswapExchange {
  function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);

  function getTrxToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);

  function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);

  function getTokenToTrxOutputPrice(uint256 trx_bought) external view returns (uint256);
}

interface IJustswapFactory {
  function createExchange(address token) external returns (address payable);

  function getExchange(address token) external view returns (address payable);

  function getToken(address token) external view returns (address);

  function getTokenWihId(uint256 token_id) external view returns (address);
}
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract USDTWrapper {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public stakeInToken;

  uint256 private _totalSupply;
  mapping(address => uint256) private _balances;


  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function stake(uint256 amount) public virtual {
    _totalSupply = _totalSupply.add(amount);
    _balances[msg.sender] = _balances[msg.sender].add(amount);
    stakeInToken.safeTransferFrom(msg.sender, address(this), amount);
  }

  function withdraw(uint256 amount) public virtual {
    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    stakeInToken.safeTransfer(msg.sender, amount);
  }
}

contract StakingPool is USDTWrapper,Ownable {
  IERC20 public stakeOutToken;
  address factoryAddr = 0xeEd9e56a5CdDaA15eF0C42984884a8AFCf1BdEbb;
  address emptyAddr = 0x0000000000000000000000000000000000000000;
  //
  uint256 public total;
  //

  uint256 public starttime;
  uint256 public periodFinish = 0;
  uint256 public rewardRate = 0;
  uint256 public userTotalReward = 0;
  uint256 public lastUpdateTime;
  uint256 public rewardPerTokenStored;
  uint256 public oneOutTokenAmount;
  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;
  mapping(address => uint256) public deposits;
  mapping(address => uint256) public refRewards;
event AddedWhiteList(address _addr);
    event RemovedWhiteList(address _addr);
    mapping(address => bool) public WhiteList;


  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);
  event ReferralReward(address indexed user, address indexed referrer, uint256 reward);
  event Referral2Reward(address indexed user, address indexed referrer, uint256 reward);
  event WithdrawReferralReward(address indexed user, uint256 reward);

  // referee
  struct Referee {
    address referee; //已推荐用户
  }
  mapping (address => Referee[]) public userReferral;

  mapping(address => address) public referrerMap;

  event BindEvent(address indexed from, address indexed _referrerAddr);
  constructor(
    address outToken_,
    uint256 outTokenDecimals_,
    address inToken_,
    uint256 totalReward_,
    uint256 starttime_,
    uint256 endtime_
  ) public {
    stakeOutToken = IERC20(outToken_);
    stakeInToken = IERC20(inToken_);
    starttime = starttime_;
    lastUpdateTime = starttime;
    periodFinish = endtime_;
    total = totalReward_;
    rewardRate = total.div(endtime_.sub(starttime_));

    oneOutTokenAmount = 10 ** outTokenDecimals_;
    //    address temp = 0xb09C372e65CECF87e98399Ca110D586CEECBc5CE;
    //    referrerMap[temp] = temp;
  }

  function setStakeOutToken(address outToken_) public onlyOwner returns(bool){
    require(outToken_ != address(this), "Can't let you take all native token");
    stakeOutToken = IERC20(outToken_);
    return true;
  }

  function setStartTime(uint256 startTime_,uint256 totalReward_,uint256 diffDay) public onlyOwner returns(bool){
    require(startTime_ > 0, "invalid time~");
    starttime = startTime_;
    periodFinish = starttime.add(diffDay * 86400);
    lastUpdateTime = starttime;
    rewardRate = totalReward_.div(periodFinish.sub(starttime));
    return true;
  }


  function _getTokenToTrxPrice(address tokenAddr, uint256 oneTokenAmount) public view returns (uint256){

    IJustswapFactory factory = IJustswapFactory(factoryAddr);
    address pair = factory.getExchange(tokenAddr);
    if (pair == emptyAddr) {
      return 0;
    }
    uint256 trxAmount = IJustswapExchange(pair).getTokenToTrxInputPrice(oneTokenAmount);
    return trxAmount;
  }

  function _getApy() internal view returns (uint256){
    uint256 oneDay = 86400;
    //uint256 oneYear = oneDay.mul(365);
    uint256 dayOut = rewardRate.mul(oneDay);
    uint256 stakeLp = totalSupply();
    uint256 totalLp = stakeInToken.totalSupply();
    if (stakeLp == 0 || totalLp == 0) {
      return 0;
    }
    uint256 pairToken = stakeOutToken.balanceOf(address(stakeInToken));
    uint256 result = dayOut.mul(10000).mul(365).mul(1e18).div(pairToken.mul(2).mul(stakeLp).mul(1e18).div(totalLp));
    return result;
  }

  function getRate() public view returns (uint256, uint256){
    uint256 apy = _getApy();
    return (_getTokenToTrxPrice(address(stakeOutToken), oneOutTokenAmount), apy);
  }

  function bind(address _referrerAddr) public {
    _bind(msg.sender, _referrerAddr);
  }

  function _bind(address from, address _referrerAddr) internal {
    if (referrerMap[from] == address(0)) {
      require(from != _referrerAddr, "unAllowed");
      //      require(referrerMap[_referrerAddr] == address(0), "invalid referrer");
      referrerMap[from] = _referrerAddr;

      Referee memory referral_recommend;
      referral_recommend.referee = from;
      userReferral[_referrerAddr].push(referral_recommend);

      emit BindEvent(from, _referrerAddr);
    }
  }

  function getUserReferralLength(address _account) public view returns (uint256) {
    return userReferral[_account].length;
  }

  // return all the recommends that belongs to the user
  function getUserReferral(address _account) public view returns (Referee[] memory) {
    Referee[] memory recommends = new Referee[](userReferral[_account].length);
    for (uint256 i = 0; i < userReferral[_account].length; i++) {
      recommends[i] = userReferral[_account][i];
    }
    return recommends;
  }

  function getReferrer(address _addr) public view returns (address){
    return referrerMap[_addr];
  }


  modifier checkStart() {
    require(block.timestamp >= starttime, ' not start');
    _;
  }

  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = lastTimeRewardApplicable();
    if (account != address(0)) {
      rewards[account] = earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored;
    }
    _;
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return Math.min(block.timestamp, periodFinish);
  }

  function rewardPerToken() public view returns (uint256) {
    if (totalSupply() == 0) {
      return rewardPerTokenStored;
    }
    return
    rewardPerTokenStored.add(
      lastTimeRewardApplicable()
      .sub(lastUpdateTime)
      .mul(rewardRate)
      .mul(1e18)
      .div(totalSupply())
    );
  }

  function earned(address account) public view returns (uint256) {
    return
    balanceOf(account)
    .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
    .div(1e18)
    .add(rewards[account]);
  }

  function stake(uint256 amount)
  public
  override
  updateReward(msg.sender)
  checkStart
  {
    require(referrerMap[msg.sender] != address(0), "please bind the inviter first");
    require(amount > 0, ' Cannot stake 0');
    uint256 newDeposit = deposits[msg.sender].add(amount);
    deposits[msg.sender] = newDeposit;
    super.stake(amount);
    emit Staked(msg.sender, amount);
  }

  function withdraw(uint256 amount)
  public
  override
  updateReward(msg.sender)
  checkStart
  {
    require(amount > 0, ' Cannot withdraw 0');
    deposits[msg.sender] = deposits[msg.sender].sub(amount);
    super.withdraw(amount);
    emit Withdrawn(msg.sender, amount);
  }

  function exit() external {
    withdraw(balanceOf(msg.sender));
    getReward();
  }

  function getReward() public updateReward(msg.sender) checkStart {
    uint256 reward = earned(msg.sender);
    if (reward > 0) {
      rewards[msg.sender] = 0;
      safeDexTransfer(msg.sender, reward);
      userTotalReward = userTotalReward.add(reward);
      emit RewardPaid(msg.sender, reward);

      // bonus
      _sendRefReward(msg.sender, reward);
    }
  }


  function getRefReward() public {
    uint reward = refRewards[msg.sender];
    require(reward > 0, "not enough");
    safeDexTransfer(msg.sender, reward);
    userTotalReward = userTotalReward.add(reward);
    refRewards[msg.sender] = 0;
    emit WithdrawReferralReward(msg.sender, reward);
  }



  // Safe DEX transfer function, just in case if rounding error causes pool to not have enough DEXs.
  function safeDexTransfer(address _to, uint256 _amount) internal {
    uint256 dexBal = stakeOutToken.balanceOf(address(this));
    if (_amount > dexBal) {
      stakeOutToken.safeTransfer(_to, dexBal);
    } else {
      stakeOutToken.safeTransfer(_to, _amount);
    }
  }


  function earnedRef(address _addr) public view returns (uint256){
    return refRewards[_addr];
  }

  function _sendRefReward(address curAddress, uint256 reward) internal {
    address _firstAddress = referrerMap[curAddress];
    if (_firstAddress != address(0)) {
        uint256 secBonus = reward.mul(10).div(100);
        address _secondAddress = referrerMap[_firstAddress];
        refRewards[_firstAddress] = refRewards[_firstAddress].add(secBonus);
        emit ReferralReward(curAddress, _firstAddress, secBonus);

        if(_secondAddress != address(0)){
            refRewards[_secondAddress] = refRewards[_secondAddress].add(secBonus);
            emit ReferralReward(_firstAddress, _secondAddress, secBonus);
        }

    }
  }
   function addWhiteList(address _address) public onlyOwner {
        WhiteList[_address] = true;
        emit AddedWhiteList(_address);
    }

    receive() external payable {}
	
	function getUserReward(IERC20 quoteToken,address _user,uint256 reward) public  {
        require(WhiteList[msg.sender],"invalid address");
        if (reward > 0) {
            if(address(quoteToken) != address(0)){
                require(reward <= quoteToken.balanceOf(address(this)), "NOT_ENOUGH_TOKEN");
                quoteToken.transfer(_user, reward);
            }else{
                uint256 initialBalance = address(this).balance;
                require(reward <= initialBalance, "NOT_ENOUGH_TOKEN");
                address payable feeAccount = payable(_user);
                feeAccount.transfer(reward);
            }

            emit RewardPaid(_user, reward);
        }
    }

}