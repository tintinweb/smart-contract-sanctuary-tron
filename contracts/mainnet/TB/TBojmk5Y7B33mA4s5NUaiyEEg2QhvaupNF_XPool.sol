//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0; 

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


//SourceUnit: IJustswapExchange.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IJustswapExchange {
    event TokenPurchase(
        address indexed buyer,
        uint256 indexed trx_sold,
        uint256 indexed tokens_bought
    );
    event TrxPurchase(
        address indexed buyer,
        uint256 indexed tokens_sold,
        uint256 indexed trx_bought
    );
    event AddLiquidity(
        address indexed provider,
        uint256 indexed trx_amount,
        uint256 indexed token_amount
    );
    event RemoveLiquidity(
        address indexed provider,
        uint256 indexed trx_amount,
        uint256 indexed token_amount
    );

    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);

    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);

    function trxToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256);

    function trxToTokenTransferInput(
        uint256 min_tokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256);

    function trxToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
        external
        payable
        returns (uint256);

    function trxToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256);

    function tokenToTrxSwapInput(
        uint256 tokens_sold,
        uint256 min_trx,
        uint256 deadline
    ) external returns (uint256);

    function tokenToTrxTransferInput(
        uint256 tokens_sold,
        uint256 min_trx,
        uint256 deadline,
        address recipient
    ) external returns (uint256);

    function tokenToTrxSwapOutput(
        uint256 trx_bought,
        uint256 max_tokens,
        uint256 deadline
    ) external returns (uint256);

    function tokenToTrxTransferOutput(
        uint256 trx_bought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256);

    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_trx_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_trx_bought,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_trx_sold,
        uint256 deadline,
        address token_addr
    ) external returns (uint256);

    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_trx_sold,
        uint256 deadline,
        address recipient,
        address token_addr
    ) external returns (uint256);

    function tokenToExchangeSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_trx_bought,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeTransferInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_trx_bought,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeSwapOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_trx_sold,
        uint256 deadline,
        address exchange_addr
    ) external returns (uint256);

    function tokenToExchangeTransferOutput(
        uint256 tokens_bought,
        uint256 max_tokens_sold,
        uint256 max_trx_sold,
        uint256 deadline,
        address recipient,
        address exchange_addr
    ) external returns (uint256);

    function getTrxToTokenInputPrice(uint256 trx_sold)
        external
        view
        returns (uint256);

    function getTrxToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256);

    function getTokenToTrxInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256);

    function getTokenToTrxOutputPrice(uint256 trx_bought)
        external
        view
        returns (uint256);

    function tokenAddress() external view returns (address);

    function factoryAddress() external view returns (address);

    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    ) external payable returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 min_trx,
        uint256 min_tokens,
        uint256 deadline
    ) external returns (uint256, uint256);
}


//SourceUnit: IJustswapFactory.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IJustswapFactory {
    event NewExchange(address indexed token, address indexed exchange);

    function initializeFactory(address template) external;

    function createExchange(address token) external returns (address payable);

    function getExchange(address token) external view returns (address payable);

    function getToken(address token) external view returns (address);

    function getTokenWihId(uint256 token_id) external view returns (address);
}


//SourceUnit: ITRC20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

/**
 * @title TRC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface ITRC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


//SourceUnit: Pausable.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() public {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

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


//SourceUnit: SafeTRC20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./ITRC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeTRC20
 * @dev Wrappers around TRC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeTRC20 for TRC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeTRC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ITRC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ITRC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ITRC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ITRC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ITRC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(ITRC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

//SourceUnit: XPool.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./Address.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./SafeMath.sol";
import "./ITRC20.sol";
import "./SafeTRC20.sol";
import "./IJustswapExchange.sol";
import "./IJustswapFactory.sol";

contract XPool is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeTRC20 for ITRC20;
    using Address for address;

    address private _xToken;
    address private _usdt;
    address private _factory;

    bool private _init = false;

    uint256 private _seg = 1000;
    uint256 private _spot = 150;

    bool private _repurchaseEnable = false;

    uint256 private _depositAmountMinLimit;
    uint256 private _depositAmountMaxLimit;

    address public constant HOLE =
        address(0x000000000000000000000000000000000000dEaD);

    uint256 private _hashrateIncPercent = 10;
    uint256 private _hashrateIncLimitDay = 100;
    uint256 public constant PERCISION = 1000;

    uint256 private _activeValue = 50;
    uint256 public constant INV_AWARD = 100;
    uint256 public constant AWARD_TIRE = 9;
    address private _root;
    address private _market;
    mapping(address => address) private _referee;
    mapping(address => address[]) private _refers;
    mapping(address => uint256) private _referAward;

    constructor(
        address root_,
        address market_,
        address xToken_,
        address usdt_,
        address factory_
    ) public {
        _root = root_;
        _market = market_;
        _xToken = xToken_;
        _usdt = usdt_;
        _factory = factory_;

        _depositAmountMinLimit = 10**uint256(ITRC20(_usdt).decimals() - 1);
        _depositAmountMaxLimit = 2000 * 10**uint256(ITRC20(_usdt).decimals());
    }

    struct Pool {
        uint256 hashrate;
        uint256 accBonusPerShare;
        uint256 ismPerBlock;
        uint256 lastRewardTime;
        uint256 startTime;
        uint256 lastIncTime;
        uint256 incPerDay;
    }

    Pool private _pool;

    struct Miner {
        uint256 hashrate;
        uint256 bonus;
        uint256 rewardDebt;
        uint256 out;
    }

    mapping(address => Miner) private _miners;

    address[] private _supportTokenList;
    mapping(address => uint256) _supportTokenPower;
    mapping(address => uint256) _supportTokenConsume;
    mapping(address => uint256) _supportTokenHashrate;
    mapping(address => uint256) _supportTokenIn;

    function init() public view returns (bool) {
        return _init;
    }

    function seg() public view returns (uint256) {
        return _seg;
    }

    function spot() public view returns (uint256) {
        return _spot;
    }

    function xToken() public view returns (address) {
        return _xToken;
    }

    function repurchaseEnable() public view returns (bool) {
        return _repurchaseEnable;
    }

    function usdt() public view returns (address) {
        return _usdt;
    }

    function activeValue() public view returns (uint256) {
        return _activeValue;
    }

    function xEx() public view returns (address) {
        return IJustswapFactory(_factory).getExchange(_xToken);
    }

    function usdtEx() public view returns (address) {
        return IJustswapFactory(_factory).getExchange(_usdt);
    }

    function factory() public view returns (address) {
        return _factory;
    }

    function hashrateIncPercent() public view returns (uint256) {
        return _hashrateIncPercent;
    }

    function root() public view returns (address) {
        return _root;
    }

    function market() public view returns (address) {
        return _market;
    }

    function refAward(address account) public view returns (uint256) {
        return _referAward[account];
    }
    function hashrateIncLimitDay() public view returns (uint256) {
        return _hashrateIncLimitDay;
    }
    function refInfo(address account)
        public
        view
        returns (
            address referee,
            uint256 count,
            uint256 award
        )
    {
        referee = _referee[account];
        count = _refers[account].length;
        award = _referAward[account];
    }

    function pool()
        public
        view
        returns (
            uint256 hashrate,
            uint256 acc,
            uint256 ism,
            uint256 lastRewardTime,
            uint256 startTime,
            uint256 lastIncTime,
            uint256 incPerDay
        )
    {
        hashrate = _pool.hashrate;
        acc = _pool.accBonusPerShare;
        ism = _pool.ismPerBlock;
        lastRewardTime = _pool.lastRewardTime;
        startTime = _pool.startTime;
        lastIncTime = _pool.lastIncTime;
        incPerDay = _pool.incPerDay;
    }

    function depositAmountLimit()
        public
        view
        returns (uint256 min, uint256 max)
    {
        min = _depositAmountMinLimit;
        max = _depositAmountMaxLimit;
    }

    function supportTokenList() public view returns (address[] memory) {
        return _supportTokenList;
    }

    function supportTokenPower(uint256 tid) public view returns (uint256) {
        return _supportTokenPower[_supportTokenList[tid]];
    }

    function supportTokenConsume(uint256 tid) public view returns (uint256) {
        return _supportTokenConsume[_supportTokenList[tid]];
    }

    function supportTokenIn(uint256 tid) public view returns (uint256) {
        return _supportTokenIn[_supportTokenList[tid]];
    }

    function supportTokenHashrate(uint256 tid) public view returns (uint256) {
        return _supportTokenHashrate[_supportTokenList[tid]];
    }

    function supportTokenInfos()
        public
        view
        returns (
            address[] memory tokens,
            uint256[] memory powers,
            uint256[] memory ins,
            uint256[] memory hashrates,
            uint256[] memory consumes
        )
    {
        uint256 length = _supportTokenList.length;
        tokens = new address[](length);
        ins = new uint256[](length);
        hashrates = new uint256[](length);
        powers = new uint256[](length);
        consumes = new uint256[](length);
        for (uint256 i = 0; i < _supportTokenList.length; i++) {
            tokens[i] = _supportTokenList[i];
            powers[i] = _supportTokenPower[_supportTokenList[i]];
            ins[i] = _supportTokenIn[_supportTokenList[i]];
            hashrates[i] = _supportTokenHashrate[_supportTokenList[i]];
            consumes[i] = _supportTokenConsume[_supportTokenList[i]];
        }
    }

    function referee(address account) public view returns (address) {
        return _referee[account];
    }

    function refers(address account) public view returns (address[] memory) {
        return _refers[account];
    }

    function referAward(address account) public view returns (uint256) {
        return _referAward[account];
    }

    function _getDay() private view returns (uint256) {
        return _toDay(block.timestamp);
    }

    function _toDay(uint256 t) private pure returns (uint256) {
        return t.div(3600 * 24);
    }

    function _isActive(address account) private view returns (bool) {
        return (_referee[account] != address(0) || account == _root);
    }

    function isActive(address account) public view returns (bool) {
        return _isActive(account);
    }

    function _active(address account, address r) private {
        uint256 value = msg.value;
        require(value == _activeValue, "XPool: Unusable amount");
        require(account != r, "XPool: Cannot invite yourself");
        require(!_isActive(account), "XPool: Already active");
        require(_isActive(r), "XPool: invitor illegal");

        _referee[account] = r;
        _refers[r].push(account);

        uint256 balance = _activeValue;
        address parent = r;
        for (uint256 i = 0; i < AWARD_TIRE; i++) {
            if (parent == address(0)) break;
            if (_refers[parent].length > i) {
                uint256 award = _activeValue.mul(INV_AWARD).div(PERCISION);
                parent.toPayable().transfer(award);
                _referAward[parent] = award.add(_referAward[parent]);
                balance = balance.sub(award);
            }
            parent = _referee[parent];
        }
        _root.toPayable().transfer(balance);
        _referAward[_root] = balance.add(_referAward[_root]);
    }

    function _getSpacingTime() private view returns (uint256) {
        if (block.timestamp < _pool.lastRewardTime) {
            return 0;
        } else {
            return block.timestamp.sub(_pool.lastRewardTime);
        }
    }

    function _updateBonusShare() private {
        if (_pool.hashrate == 0) {
            return;
        }
        uint256 spacingTime = _getSpacingTime();
        uint256 ismReward = spacingTime.mul(_pool.ismPerBlock).mul(1e18).div(
            _pool.hashrate
        );
        _pool.accBonusPerShare = ismReward.add(_pool.accBonusPerShare);
        _pool.lastRewardTime = block.timestamp;
    }

    function _updateYield() private {
        uint256 day = _getDay();
        uint256 lastIncDayTime = _toDay(_pool.lastIncTime);
        if (day > lastIncDayTime) {
            uint256 inc = (day.sub(lastIncDayTime)).mul(_pool.incPerDay).div(
                86400
            );
            _pool.ismPerBlock = _pool.ismPerBlock.add(inc);
            _pool.lastIncTime = block.timestamp;
        }
    }

    function _reflectUSDT2TokenAmount(address token, uint256 amount)
        private
        view
        returns (uint256)
    {
        uint256 uDec = 10**uint256(ITRC20(_usdt).decimals());
        return amount.mul(_supportTokenPower[token]).div(uDec);
    }

    function _reflectHashrate(address token, uint256 amount)
        private
        view
        returns (uint256 hashrate, uint256 tokenAmount)
    {
        hashrate = amount.mul(2).mul(10);
        uint256 startDayTime = _toDay(_pool.startTime);
        require(_getDay() >= startDayTime, "XPool: Unavailable time");
        uint256 diff = _getDay().sub(startDayTime);
        if (diff > _hashrateIncLimitDay) {
            diff = _hashrateIncLimitDay;
        }
        uint256 incHashrate = hashrate
            .mul(_hashrateIncPercent)
            .div(PERCISION)
            .mul(diff);
        hashrate = incHashrate.add(hashrate);
        tokenAmount = _reflectUSDT2TokenAmount(token, amount);
    }

    function _getSwapValue(
        address tokenAEx,
        address tokenBEx,
        uint256 amount
    ) private view returns (uint256 v, uint256 min) {
        v = amount.mul(_seg).div(PERCISION);
        uint256 v2 = IJustswapExchange(tokenAEx).getTokenToTrxInputPrice(v);
        uint256 v3 = IJustswapExchange(tokenBEx).getTrxToTokenInputPrice(v2);
        min = v3.sub(v3.mul(_spot).div(PERCISION));
    }

    function _deposit(
        address account,
        uint256 tid,
        uint256 amount,
        uint256 deadline
    ) private {
        require(
            _pool.startTime > 0 && block.timestamp > _pool.startTime,
            "XPool: Not open"
        );
        require(tid < _supportTokenList.length, "XPool: Unavailable token");
        require(
            amount >= _depositAmountMinLimit &&
                amount <= _depositAmountMaxLimit,
            "XPool: Unavailable amount"
        );
        address token = _supportTokenList[tid];
        (uint256 hashrate, uint256 tokenAmount) = _reflectHashrate(
            token,
            amount
        );

        ITRC20(_usdt).safeTransferFrom(msg.sender, address(this), amount);
        ITRC20(token).safeTransferFrom(msg.sender, address(HOLE), tokenAmount);
        _supportTokenConsume[token] = tokenAmount.add(
            _supportTokenConsume[token]
        );
        _supportTokenHashrate[token] = hashrate.add(
            _supportTokenHashrate[token]
        );
        _supportTokenIn[token] = amount.add(_supportTokenIn[token]);
        if (_repurchaseEnable) {
            address _usdtEx = IJustswapFactory(_factory).getExchange(_usdt);
            address _xTokenEx = IJustswapFactory(_factory).getExchange(_xToken);
            (uint256 v, uint256 min) = _getSwapValue(
                _usdtEx,
                _xTokenEx,
                ITRC20(_usdt).balanceOf(address(this))
            );
            ITRC20(_usdt).approve(_usdtEx, v);
            IJustswapExchange(_usdtEx).tokenToTokenTransferInput(
                v,
                min,
                1,
                deadline,
                address(HOLE),
                _xToken
            );
        }
        if (ITRC20(_usdt).balanceOf(address(this)) > 0) {
            ITRC20(_usdt).transfer(
                _market,
                ITRC20(_usdt).balanceOf(address(this))
            );
        }
        _updateBonusShare();
        uint256 bonus = 0;
        if (_miners[account].hashrate > 0) {
            bonus = _miners[account].hashrate.mul(_pool.accBonusPerShare).div(
                1e18
            );
            bonus = bonus.sub(_miners[account].rewardDebt);
        }
        _miners[account].bonus = bonus.add(_miners[account].bonus);
        _miners[account].hashrate = hashrate.add(_miners[account].hashrate);
        _miners[account].rewardDebt = _miners[account]
            .hashrate
            .mul(_pool.accBonusPerShare)
            .div(1e18);
        _pool.hashrate = hashrate.add(_pool.hashrate);
        _updateYield();
    }

    function _viewEarnings(address account) private view returns (uint256) {
        uint256 bonus = 0;
        uint256 acc = _pool.accBonusPerShare;
        Miner memory miner = _miners[account];
        if (miner.hashrate > 0) {
            uint256 spacingTime = _getSpacingTime();
            uint256 ismReward = spacingTime
                .mul(_pool.ismPerBlock)
                .mul(1e18)
                .div(_pool.hashrate);
            acc = ismReward.add(acc);
            bonus = miner.hashrate.mul(acc).div(1e18);
            bonus = bonus.sub(miner.rewardDebt);
        }
        return bonus.add(miner.bonus);
    }

    function _claim(address account) private {
        _updateBonusShare();
        uint256 bonus;
        if (_miners[account].hashrate > 0) {
            bonus = _miners[account].hashrate.mul(_pool.accBonusPerShare).div(
                1e18
            );
            bonus = bonus.sub(_miners[account].rewardDebt);
            bonus = bonus.add(_miners[account].bonus);
            ITRC20(_xToken).safeTransfer(account, bonus);
            _miners[account].out = _miners[account].out.add(bonus);
            _miners[account].bonus = 0;
            _miners[account].rewardDebt = _miners[account]
                .hashrate
                .mul(_pool.accBonusPerShare)
                .div(1e18);
        }
        _updateYield();
    }

    function getSwapValue(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256 v, uint256 min) {
        address tokenAEx = IJustswapFactory(_factory).getExchange(tokenA);
        address tokenBEx = IJustswapFactory(_factory).getExchange(tokenB);
        (v, min) = _getSwapValue(tokenAEx, tokenBEx, amount);
    }

    function reflectHashrate(uint256 tid, uint256 amount)
        public
        view
        returns (uint256 hashrate, uint256 tokenAmount)
    {
        (hashrate, tokenAmount) = _reflectHashrate(
            _supportTokenList[tid],
            amount
        );
    }

    function reflectUSDT2TokenAmount(uint256 tid, uint256 amount)
        public
        view
        returns (uint256)
    {
        return _reflectUSDT2TokenAmount(_supportTokenList[tid], amount);
    }

    function viewEarnings(address account) public view returns (uint256) {
        return _viewEarnings(account);
    }

    function deposit(
        uint256 tid,
        uint256 amount,
        uint256 deadline
    ) public whenNotPaused {
        require(_isActive(_msgSender()), "XPool: Require active");
        _deposit(_msgSender(), tid, amount, deadline);
    }

    function claim() public whenNotPaused {
        require(_isActive(_msgSender()), "XPool: Require active");
        _claim(_msgSender());
    }

    function active(address r) public payable whenNotPaused {
        _active(_msgSender(), r);
    }

    function miner(address account)
        public
        view
        returns (
            uint256 hashrate,
            uint256 bonus,
            uint256 rewardDebt,
            uint256 out
        )
    {
        hashrate = _miners[account].hashrate;
        bonus = _viewEarnings(account);
        rewardDebt = _miners[account].rewardDebt;
        out = _miners[account].out;
    }

    function addToken(address token, uint256 price) public onlyOwner {
        _supportTokenList.push(token);
        _supportTokenPower[token] = price;
    }

    function addTokens(address[] memory tokens, uint256[] memory prices)
        public
        onlyOwner
    {
        require(
            tokens.length == prices.length,
            "XPool: Unvaliable param, length must equal"
        );
        for (uint256 i = 0; i < tokens.length; i++) {
            addToken(tokens[i], prices[i]);
        }
    }

    function editToken(
        uint256 tid,
        address token,
        uint256 price
    ) public onlyOwner {
        require(tid < _supportTokenList.length, "XPool: Unvaliable tid");
        _supportTokenPower[_supportTokenList[tid]] = 0;
        _supportTokenList[tid] = token;
        _supportTokenPower[token] = price;
    }

    function initPool(
        uint256 startTime,
        uint256 ismPerBlock,
        uint256 incPerDay
    ) public onlyOwner {
        require(!_init, "XPool: Operation not allow");
        _init = true;
        _pool.startTime = startTime;
        _pool.lastIncTime = startTime;
        _pool.ismPerBlock = ismPerBlock;
        _pool.incPerDay = incPerDay;
        _pool.lastRewardTime = startTime;
    }

    function updateYield() public onlyOwner {
        _updateBonusShare();
        _updateYield();
    }

    function setPoolYield(uint256 ismPerBlock) public onlyOwner {
        updateYield();
        _pool.ismPerBlock = ismPerBlock;
    }

    function setPoolIncPerDay(uint256 incPerDay) public onlyOwner {
        updateYield();
        _pool.incPerDay = incPerDay;
    }

    function setDepositAmountLimit(uint256 min, uint256 max) public onlyOwner {
        _depositAmountMinLimit = min;
        _depositAmountMaxLimit = max;
    }

    function setSeg(uint256 seg_) public onlyOwner {
        _seg = seg_;
    }

    function setMarket(address market_) public onlyOwner {
        _market = market_;
    }

    function setSpot(uint256 spot_) public onlyOwner {
        _spot = spot_;
    }

    function setHashrateIncLimitDay(uint256 hashrateIncLimitDay_) public onlyOwner {
        _hashrateIncLimitDay = hashrateIncLimitDay_;
    }

    function setRepurchaseEnable(bool repurchaseEnable_) public onlyOwner {
        _repurchaseEnable = repurchaseEnable_;
    }

    function setActiveValue(uint256 activeValue_) public onlyOwner {
        _activeValue = activeValue_;
    }

    function setHashrateIncPercent(uint256 hashrateIncPercent_)
        public
        onlyOwner
    {
        _hashrateIncPercent = hashrateIncPercent_;
    }
}