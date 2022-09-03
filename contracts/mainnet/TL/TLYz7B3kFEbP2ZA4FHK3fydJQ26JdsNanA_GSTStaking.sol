//SourceUnit: tronContract.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        (bool success, ) = recipient.call{ value: amount }("");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

abstract contract Ownable is Context {
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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract GSTStaking is Ownable,ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct PoolInfo {
        uint256 lockupDuration;
        uint returnPer;
    }
    struct OrderInfo {
        address beneficiary;
        uint256 amount;
        uint256 lockupDuration;
        uint returnPer;
        uint256 starttime;
        uint256 endtime;
        uint256 claimedReward;
        bool claimed;
    }
    IERC20 public token;
    bool public started = true;
    uint256 public emergencyWithdrawFess = 1500; // 20% ~ 200
    uint256 public WithdrawFee = 500;
    uint256 public adminFee = 500;
    uint256 public totalRewardPending;
    address public feesRecevier;
    
    mapping(uint256 => PoolInfo) public pooldata;
    /// @dev balanceOf[investor] = balance
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public totalRewardEarn;

    mapping(uint256 => OrderInfo) public orders;
    uint256 private latestOrderId = 0;
    mapping(address => uint256[]) private orderIds;

    uint public totalStake = 0;
    uint public totalWithdrawal = 0;
    uint public totalRewardsDistribution = 0;
    uint8 public MIN_REWARD_TIME = 1; //in days
    uint256 public MIN_REWARD_AMOUNT = 15000000000000000000;
    uint256 public baseTime = 86400;

    //Referral Part

    using SafeMath for uint;

    /**
    * @dev Max referral level depth
    */
    uint8 constant MAX_REFER_DEPTH = 1;

    /**
    * @dev Max referee amount to bonus rate depth
    */
    uint8 constant MAX_REFEREE_BONUS_LEVEL = 1;


    /**
    * @dev The struct of account information
    * @param referrer The referrer addresss
    * @param reward The total referral reward of an address
    * @param referredCount The total referral amount of an address
    * @param lastActiveTimestamp The last active timestamp of an address
    */
    struct Account {
        address referrer; 
        uint reward;
        uint referredCount;
        uint lastActiveTimestamp;
    }

    /**
    * @dev The struct of referee amount to bonus rate
    * @param lowerBound The minial referee amount
    * @param rate The bonus rate for each referee amount
    */
    struct RefereeBonusRate {
        uint lowerBound;
        uint rate;
    }

    event RegisteredReferer(address referee, address referrer);
    event RegisteredRefererFailed(address referee, address referrer, string reason);
    event PaidReferral(address from, address to, uint amount, uint level);
    event UpdatedUserLastActiveTime(address user, uint timestamp);
    
    mapping(address => Account) public accounts;

    uint256[] levelRate;
    uint256 referralBonus = 100000;
    uint256 decimals = 100000;
    uint256 secondsUntilInactive = 31536000;
    bool onlyRewardActiveReferrers = false;
    
    constructor(
       address _token,
       bool _started,
       uint8 _min_reward_time,
       uint256 _emergencyWithdrawFess,
      uint256[] memory _levelRate
    ) public {
        token = IERC20(_token);
        started = _started;
        MIN_REWARD_TIME = _min_reward_time;
        emergencyWithdrawFess = _emergencyWithdrawFess;

        require(_levelRate.length > 0, "Referral level should be at least one");
        require(_levelRate.length <= MAX_REFER_DEPTH, "Exceeded max referral level depth");
        require(referralBonus <= decimals, "Referral bonus exceeds 100%");
        require(sum(_levelRate) <= decimals, "Total level rate exceeds 100%");

        levelRate = _levelRate;

        pooldata[30].lockupDuration = 30;
        pooldata[30].returnPer = 2000; // 30%

        //90 days
        pooldata[60].lockupDuration = 60;
        pooldata[60].returnPer = 3000; // 50%

        //180 days

        pooldata[120].lockupDuration = 120;
        pooldata[120].returnPer = 3500; // 80%

        pooldata[365].lockupDuration = 365;
        pooldata[365].returnPer = 4500; // 120%

    }

    event Deposit(address indexed user, uint256 indexed lockupDuration, uint256 amount , uint returnPer);
    event Withdraw(address indexed user, uint256 amount , uint256 reward , uint256 total );
    event WithdrawAll(address indexed user, uint256 amount);
    
    
    function addPool(uint256 _lockupDuration , uint _returnPer ) external onlyOwner {
        require(_lockupDuration > 0 , "LockupDuration must be greater than zero");
        require(_returnPer > 0 , "ReturnPer must be greater than zero");
        PoolInfo storage pool = pooldata[_lockupDuration];
        pool.lockupDuration = _lockupDuration;
        pool.returnPer = _returnPer;

    }

    function setAdminFee(uint256 _fees) public onlyOwner{
        adminFee = _fees;
    }

    function setWithdrawFee(uint256 _fees) public onlyOwner{
        WithdrawFee = _fees;
    }

    function setFeesRecevierWallet(address _walletAddress) public onlyOwner{
        require(_walletAddress != address(0), "Zero Address Found !!");
        feesRecevier = _walletAddress;
    }

    function investorOrderIds(address investor)
        external
        view
        returns (uint256[] memory ids)
    {
        uint256[] memory arr = orderIds[investor];
        return arr;
    }

    function setreferralBonus(uint256 _bonousRate) public onlyOwner{
        referralBonus = _bonousRate;
    }

    function setLevelRate(uint256[] memory _levelRate) public onlyOwner{
        levelRate = _levelRate;
    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function toggleStaking(bool _start) external onlyOwner {
        started = _start;
    }


    function setMinRewardClaimTime(uint8 _days) external onlyOwner{
        MIN_REWARD_TIME = _days;
    }

    function setMinRewardClaim(uint256 _amount) external onlyOwner{
        MIN_REWARD_AMOUNT = _amount;
    }
    
     function setBaseTime(uint256 _baseTime) external onlyOwner{
        baseTime = _baseTime;
    }

    

    function pendingRewards(uint256 _orderId ) external view returns (uint256) {
        OrderInfo storage orderInfo = orders[_orderId];

        if(_orderId <= latestOrderId && orderInfo.amount > 0 && !orderInfo.claimed){
            
            if(block.timestamp >= orderInfo.endtime){
                uint256 reward = (orderInfo.amount.mul(orderInfo.returnPer).mul(orderInfo.lockupDuration)).div(10000*365);
                uint256 claimAvlible =  reward.sub(orderInfo.claimedReward);
                return claimAvlible;
            }
            
            uint256 stakeTime = block.timestamp.sub(orderInfo.starttime);
            uint256 totalReward = orderInfo.amount.mul(stakeTime).mul(orderInfo.returnPer).div(10000*365*86400);
            uint256 claimAvlible =  totalReward.sub(orderInfo.claimedReward);
            return claimAvlible;
        }
        else{
            return 0;
        }
        
    }

    function deposit(uint256 _amount , uint256 _lockupDuration , address _refAddress) external {
        require(address(token) != address(0), "Token Not Set Yet");
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        require(started , "Not Stared yet!");
        require(_amount > 0, "Amount must be greater than Zero!");
        
        PoolInfo storage pool = pooldata[_lockupDuration];
        
        require(pool.lockupDuration > 0 && pool.returnPer > 0 , "No Pool exist With Locktime!");
        
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        if(!hasReferrer(msg.sender)) {
            addReferrer(_refAddress);
        }

        payReferral(_amount);
       
         orders[++latestOrderId] = OrderInfo(
             msg.sender,
            _amount,
            _lockupDuration,
            pool.returnPer,
            block.timestamp,
            block.timestamp + (_lockupDuration.mul(baseTime)),
            0,
            false
        );

        uint256 userReward = (_amount.mul(pool.returnPer).mul(_lockupDuration)).div(10000*365);
        totalStake = totalStake.add(_amount);
        totalRewardPending = totalRewardPending.add(userReward);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        orderIds[msg.sender].push(latestOrderId);
        emit Deposit(msg.sender , _lockupDuration , _amount ,pool.returnPer );
    }


    function claimReward(uint256 _orderId) nonReentrant external{
        require(_orderId <= latestOrderId, "the order ID is incorrect"); // IOI
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        //Need Avlible Balance
        
        OrderInfo storage orderInfo = orders[_orderId];
        require(msg.sender == orderInfo.beneficiary, "not order beneficiary"); // NOO
        require(orderInfo.amount > 0, "insufficient redeemable tokens"); // ITA
        require(!orderInfo.claimed , "Order Already Withdraw");
        uint256 claimAvlible = 0;

        if(block.timestamp >= orderInfo.endtime){
            uint256 reward = (orderInfo.amount.mul(orderInfo.returnPer).mul(orderInfo.lockupDuration)).div(10000*365);
            claimAvlible +=  reward.sub(orderInfo.claimedReward);
        }
        else{
            uint256 stakeTime = block.timestamp.sub(orderInfo.starttime);
            uint256 stakeDays = stakeTime.div(86400); //  /86400
            require(stakeDays >= MIN_REWARD_TIME , "You can Claim After minimum claim period over");
            uint256 totalReward = orderInfo.amount.mul(stakeTime).mul(orderInfo.returnPer).div(10000*365*86400);
            claimAvlible +=  totalReward.sub(orderInfo.claimedReward);
             
        }

        require(claimAvlible >= MIN_REWARD_AMOUNT , "You Don't Have Enough Reward to Claim !");
        require(token.balanceOf(address(this)) >= claimAvlible, "Currently Withdraw not Avalible");
        
        totalRewardEarn[msg.sender] = totalRewardEarn[msg.sender].add(claimAvlible);
        orderInfo.claimedReward += claimAvlible;
        totalRewardsDistribution += claimAvlible;
        token.transfer(address(msg.sender) , claimAvlible);
        
    }

    function withdraw(uint256 orderId) nonReentrant external {
       require(orderId <= latestOrderId, "the order ID is incorrect"); // IOI
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        OrderInfo storage orderInfo = orders[orderId];
        require(msg.sender == orderInfo.beneficiary, "not order beneficiary"); // NOO
        require(balanceOf[msg.sender] >= orderInfo.amount && !orderInfo.claimed, "insufficient redeemable tokens"); // ITA
        require(block.timestamp >= orderInfo.endtime,"tokens are being locked"); // TIL

        require(!orderInfo.claimed, "tokens are ready to be claimed"); // TAC
        
        uint256 amount =  orderInfo.amount;
        uint256 adminFees = amount.mul(adminFee).div(10000);
        uint256 withdrawFees = amount.mul(WithdrawFee).div(10000);
        uint256 reward = (amount.mul(orderInfo.returnPer).mul(orderInfo.lockupDuration)).div(10000*365);
        uint256 claimAvailable =  reward.sub(orderInfo.claimedReward);
        uint256 total = amount.add(claimAvailable);
        uint256 FeesSub = total.sub(adminFees).sub(withdrawFees);
        
        require(token.balanceOf(address(this)) >= total, "Currently Withdraw not Avalible");
        
        totalRewardEarn[msg.sender] = totalRewardEarn[msg.sender].add(claimAvailable);
        totalWithdrawal = totalWithdrawal.add(amount);
        totalRewardsDistribution = totalRewardsDistribution.add(claimAvailable);
        totalRewardPending = totalRewardPending.sub(reward);
        orderInfo.claimed = true;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        token.transfer(feesRecevier , adminFees.add(withdrawFees));
        token.transfer(address(msg.sender) , FeesSub);
        
        emit Withdraw(msg.sender , amount , claimAvailable , total);
    }

    function emergencyWithdraw(uint256 orderId) nonReentrant external {
        require(orderId <= latestOrderId, "the order ID is incorrect"); // IOI
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        
        OrderInfo storage orderInfo = orders[orderId];
        require(msg.sender == orderInfo.beneficiary, "not order beneficiary"); // NOO
        require(balanceOf[msg.sender] >= orderInfo.amount && !orderInfo.claimed, "insufficient redeemable tokens or already claimed"); // ITA
       
        uint256 fees = orderInfo.amount.mul(emergencyWithdrawFess).div(10000);
        uint256 adminFees = orderInfo.amount.mul(adminFee).div(10000);
        uint256 withdrawFees = orderInfo.amount.mul(WithdrawFee).div(10000);
        uint256 total = orderInfo.amount.sub(fees).sub(adminFees).sub(withdrawFees);
        
        require(token.balanceOf(address(this)) >= total, "Currently Withdraw not Avalible");
        
        totalWithdrawal = totalWithdrawal.add(orderInfo.amount);
        orderInfo.claimed = true;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(orderInfo.amount);
        uint256 userReward = (orderInfo.amount.mul(orderInfo.returnPer).mul(orderInfo.lockupDuration)).div(10000*365);
        totalRewardPending = totalRewardPending.sub(userReward);
        token.transfer(feesRecevier , adminFees.add(withdrawFees));
        token.transfer(address(msg.sender) , total);
        emit WithdrawAll(msg.sender , total);
    } 

    function bnbLiquidity(address payable _reciever, uint256 _amount) public onlyOwner {
        _reciever.transfer(_amount); 
    }

    function transferAnyERC20Token( address payaddress ,address tokenAddress, uint256 tokens ) public onlyOwner 
    {
       IERC20(tokenAddress).transfer(payaddress, tokens);
    }


     function sum(uint[] memory data) public pure returns (uint) {
        uint S;
        for(uint i;i < data.length;i++) {
        S += data[i];
        }
        return S;
    }


    /**
    * @dev Utils function for check whether an address has the referrer
    */
    function hasReferrer(address addr) public view returns(bool){
        return accounts[addr].referrer != address(0);
    }

    /**
    * @dev Get block timestamp with function for testing mock
    */
    function getTime() public view returns(uint256) {
        return now; // solium-disable-line security/no-block-members
    }

    

    

    function isCircularReference(address referrer, address referee) internal view returns(bool){
        address parent = referrer;

        for (uint i; i < levelRate.length; i++) {
        if (parent == address(0)) {
            break;
        }

        if (parent == referee) {
            return true;
        }

        parent = accounts[parent].referrer;
        }

        return false;
    }

    /**
    * @dev Add an address as referrer
    * @param referrer The address would set as referrer of msg.sender
    * @return whether success to add upline
    */
    function addReferrer(address referrer) internal returns(bool){
        if (referrer == address(0)) {
        emit RegisteredRefererFailed(msg.sender, referrer, "Referrer cannot be 0x0 address");
        return false;
        } else if (isCircularReference(referrer, msg.sender)) {
        emit RegisteredRefererFailed(msg.sender, referrer, "Referee cannot be one of referrer uplines");
        return false;
        } else if (accounts[msg.sender].referrer != address(0)) {
        emit RegisteredRefererFailed(msg.sender, referrer, "Address have been registered upline");
        return false;
        }

        Account storage userAccount = accounts[msg.sender];
        Account storage parentAccount = accounts[referrer];

        userAccount.referrer = referrer;
        userAccount.lastActiveTimestamp = getTime();
        parentAccount.referredCount = parentAccount.referredCount.add(1);

        emit RegisteredReferer(msg.sender, referrer);
        return true;
    }

    /**
    * @dev This will calc and pay referral to uplines instantly
    * @param value The number tokens will be calculated in referral process
    * @return the total referral bonus paid
    */
    function payReferral(uint256 value) internal returns(uint256){
        Account memory userAccount = accounts[msg.sender];
        uint totalReferal;

        for (uint i; i < levelRate.length; i++) {
        address parent = userAccount.referrer;
        Account storage parentAccount = accounts[userAccount.referrer];

        if (parent == address(0)) {
            break;
        }

        if(onlyRewardActiveReferrers && parentAccount.lastActiveTimestamp.add(secondsUntilInactive) >= getTime() || !onlyRewardActiveReferrers) {
            uint c = value.mul(referralBonus).div(decimals);
            c = c.mul(levelRate[i]).div(decimals);
            // c = c.mul(getRefereeBonusRate(parentAccount.referredCount)).div(decimals);

            totalReferal = totalReferal.add(c);

            parentAccount.reward = parentAccount.reward.add(c);
            // parent.transfer(c);
            token.transfer(parent,c);
            emit PaidReferral(msg.sender, parent, c, i + 1);
        }

        userAccount = parentAccount;
        }

        updateActiveTimestamp(msg.sender);
        return totalReferal;
    }

    /**
    * @dev Developers should define what kind of actions are seens active. By default, payReferral will active msg.sender.
    * @param user The address would like to update active time
    */
    function updateActiveTimestamp(address user) internal {
        uint timestamp = getTime();
        accounts[user].lastActiveTimestamp = timestamp;
        emit UpdatedUserLastActiveTime(user, timestamp);
    }

    function setSecondsUntilInactive(uint _secondsUntilInactive) public onlyOwner {
        secondsUntilInactive = _secondsUntilInactive;
    }

    function setOnlyRewardAActiveReferrers(bool _onlyRewardActiveReferrers) public onlyOwner {
        onlyRewardActiveReferrers = _onlyRewardActiveReferrers;
    }

}