//SourceUnit: MasterGame.sol

// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }
  // solhint-disable-previous-line no-empty-blocks

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

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
   * // importANT: Beware that changing an allowance with this method brings the risk
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


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [// importANT]
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
   * // importANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    //(bool success, ) = recipient.call{ value: amount }("");
    (bool success, ) = recipient.call.value(amount)("");
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
    //===============================.call{value:weAmount}(data)
    (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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


// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

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
    if (returndata.length > 0) { // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}


// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
  // To implement this library for multiple types with as little code
  // repetition as possible, we write it in terms of a generic Set type with
  // bytes32 values.
  // The Set implementation uses private functions, and user-facing
  // implementations (such as AddressSet) are just wrappers around the
  // underlying Set.
  // This means that we can only create new EnumerableSets for types that fit
  // in bytes32.

  struct Set {
    // Storage of set values
    bytes32[] _values;

    // Position of the value in the `values` array, plus 1 because index 0
    // means a value is not in the set.
    mapping (bytes32 => uint256) _indexes;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      // The value is stored at length-1, but we add 1 to all indexes
      // and use 0 as a sentinel value
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    // We read and store the value's index to prevent multiple reads from the same storage slot
    uint256 valueIndex = set._indexes[value];

    if (valueIndex != 0) { // Equivalent to contains(set, value)
      // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
      // the array, and then remove the last element (sometimes called as 'swap and pop').
      // This modifies the order of the array, as noted in {at}.

      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;

      // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
      // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

      bytes32 lastvalue = set._values[lastIndex];

      // Move the last value to the index where the value to delete is
      set._values[toDeleteIndex] = lastvalue;
      // Update the index for the moved value
      set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

      // Delete the slot where the moved value was stored
      set._values.pop();

      // Delete the index for the deleted slot
      delete set._indexes[value];

      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }

  /**
   * @dev Returns the number of values on the set. O(1).
   */
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  // AddressSet

  struct AddressSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(value)));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(value)));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(value)));
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint256(_at(set._inner, index)));
  }


  // UintSet

  struct UintSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }

  /**
   * @dev Returns the number of values on the set. O(1).
   */
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }
}


// Root file: contracts/MasterGame.sol

//pragma solidity ^0.6.12;
pragma solidity ^0.5.14;
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";

/**
 * @dev Ticket contract interface
 */
interface ITicketsToken {
  //IERC20
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function burnFromUsdt(address account, uint256 usdtAmount) external;
  function airdrop(address account, uint256 ticketAmount) external;

  function vendingAndBurn(address account, uint256 amount) external;

  function price() external returns (uint256);

  function totalVending() external returns (uint256);
}

/**
 * @dev Master contract
 */
contract MasterGame is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;

  IERC20 usdt;
  uint256 constant usdter = 1e6;

  // Creation time
  uint256 public createdAt;
  // Total revenue
  uint256 public totalRevenue;

  // Ticket contract
  ITicketsToken ticket;

  // Static income cycle: 1 day
  uint256 constant STATIC_CYCLE = 1 days;//for prod

  // Daily prize pool cycle: 1 day
  uint256 constant DAY_POOL_CYCLE = 1 days;

  // Weekly prize pool cycle: 7 days
  uint256 constant WEEK_POOL_CYCLE = 7 days;

  // Upgrade node discount: 100 days
  uint256 constant NODE_DISCOUNT_TIME = 100 days;


  // Static rate of return, parts per ten thousand
  uint256 public staticRate = 50;
  // Dynamic rate of return, parts per thousand
  uint256[50] dynamicRates = [
  200,100,100,100,//1~4 layer
  50,50,50,50,50,50,50,50,50,50,50,//5~15 layer
  30,30,30,30,30,//16~20 level
  20,20,20,20,20,20,20,20,20,20,//21~30 layer
  10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10//31~50 layer
  ];
  // Technology founding team
  uint256[14] public founder;

  // Market value management fee
  uint256[13] public operation;

  // Insurance pool
  //uint256 public insurance;
  uint256[10] public insurance;
  // Perpetual capital pool
  uint256[13] public sustainable;

  // Dex Market making
  uint256[13] public dex;

  //third party reward pool
  uint256 public thirdPool;

  // Account ID
  uint256 public id;
  // Number of people activating Pa Point
  uint32 public nodeBurnNumber;
  // Account data
  mapping(address => Account) public accounts;
  mapping(address => AccountCount) public stats;
  // Node burn data
  mapping(address => AccountNodeBurn) public burns;
  // Team data
  mapping(address => AccountPerformance) public performances;
  mapping(address => address[]) public teams;
  // Node data
  // 1 Light node; 2 Intermediate node; 3 Super node; 4 Genesis node
  mapping(uint8 => address[]) public nodes;

  // Weekly prize pool
  uint64 public weekPoolId;
  mapping(uint64 => Pool) public weekPool;

  // Daily prize pool
  uint64 public dayPoolId;
  mapping(uint64 => Pool) public dayPool;

  // Address with a deposit of 5,000 or more
  EnumerableSet.AddressSet private richman;

  //max invest amount limit default 3000U
  uint256 public maxInvestAmount = 3000;

  //yesterday Fund pool balance
  struct YesterFundPoolBal {
    uint256 value;
    uint256 updateTime;

  }
  YesterFundPoolBal public yesFundPoolBal;


  //the flag of floating staticRate
  bool public isFloatingStaticRate;

  //invest amount limit daily
  uint256 public maxInvestAmountPerDay = 1e8;//20000 USDT
  uint256 public yesterRevenue;
  uint256 public yesterUpdateTime;

  // Account
  struct Account {
    uint256 id;
    address referrer; // Direct push
    bool reinvest; // Whether to reinvest
    uint8 nodeLevel; // Node level
    uint256 joinTime; // Join time: This value needs to be updated when joining again
    uint256 lastTakeTime; // Last time the static income was received
    uint256 deposit; // Deposited quantity: 0 means "out"
    uint256 nodeIncome; // Node revenue balance
    uint256 dayPoolIncome; // Daily bonus pool income balance
    uint256 weekPoolIncome; // Weekly bonus pool income balance
    uint256 dynamicIncome; // Dynamic income balance
    uint256 income; // Total revenue
    uint256 maxIncome; // Exit condition
    uint256 reward; // Additional other rewards
  }

  // Account statistics
  struct AccountCount {
    uint256 income; // Total revenue
    uint256 investment; // Total investment
  }

  // Performance
  struct AccountPerformance {
    uint256 performance; // Direct performance
    uint256 wholeLine; // Performance of all layers below
  }

  // Node burn
  struct AccountNodeBurn {
    bool active; // Whether to activate Node burn
    uint256 income; // Node burn income
  }

  // Prize pool
  struct Pool {
    uint256 amount; // Prize pool amount
    uint256 date; // Creation time: Use this field to determine the draw time
    mapping(uint8 => address) ranks; // Ranking: up to 256
    mapping(address => uint256) values; // Quantity/Performance
  }

  /**
   * @dev Determine whether the address is an already added address
   */
  modifier onlyJoined(address addr) {
    require(accounts[addr].id > 0, "ANR");
    _;
  }

  //Manager
  struct Manager {
    bool isManager;
    uint8 weightId;
  }
  //Manager Data
  mapping(address => Manager) public managers;
  /**
   * @dev Determine whether msg.sender is a manager
   */
  modifier onlyManagers(address _addr) {
    require(managers[_addr].isManager,"msg.sender is not a manager");

    _;
  }

  constructor(IERC20 _usdt) public {
    usdt = _usdt;

    createdAt = now;

    // Genius
    Account storage user = accounts[msg.sender];
    user.id = ++id;
    user.referrer = address(0);
    user.joinTime = now;
    user.lastTakeTime = now;
  }

  /**
   * @dev Join or reinvest the game
   */

  function join(address referrer, uint256 _amount)
  public
  onlyJoined(referrer)
  {
    require(referrer != msg.sender, "NS");
    require(_amount >= usdter.mul(100), "MIN");
    require(_amount <= usdter.mul(maxInvestAmount),"MAX");

    if(maxInvestAmountPerDay < 1e10) {
      if(now > yesterUpdateTime.add(STATIC_CYCLE)) {

        yesterRevenue = totalRevenue;
        yesterUpdateTime =now;

      }
      require(totalRevenue.sub(yesterRevenue) <= maxInvestAmountPerDay*usdter,"Today,the amount of vending exceeds limit");
    }



    // Receive USDT
    usdt.safeTransferFrom(msg.sender, address(this), _amount);

    // Burn 5%
    _handleJoinBurn(msg.sender, _amount);

    //Airdrop 10% tickets when _amount GT 1000*usdter
    if(_amount >= usdter.mul(1000)){
      _handleAirdrop(msg.sender, _amount);
    }


    Account storage user = accounts[msg.sender];
    // Create new account
    if (user.id == 0) {
      user.id = ++id;
      user.referrer = referrer;
      user.joinTime = now;
      user.lastTakeTime = now;
      // Direct team
      teams[referrer].push(msg.sender);

    }

    // Reinvest to join
    if (user.deposit != 0) {
      require(!user.reinvest, "Reinvest");

      // Can reinvest after paying back
      uint256 income = calculateStaticIncome(msg.sender)
      .add(user.dynamicIncome)
      .add(user.nodeIncome)
      .add(burns[msg.sender].income)
      .add(user.income);
      require(income >= user.deposit, "Not Coast");

      // Half or all reinvestment
      require(
        _amount == user.deposit || _amount == user.deposit.div(2),
        "FOH"
      );

      if (_amount == user.deposit) {
        // All reinvestment
        user.maxIncome = user.maxIncome.add(
          _calculateFullOutAmount(_amount)
        );
        //update lastTakeTime

        // staticIncome = user.deposit.mul(staticRate).div(10000).mul(day);
        uint256 last = user.lastTakeTime;
        uint256 day = (now - last) / STATIC_CYCLE;
        if(day < 30) {
          //// staticIncome = user.deposit.mul(2).mul(staticRate).div(10000).mul(day).div(2);
          uint256 timeGap = now - last;
          user.lastTakeTime = user.lastTakeTime.add(timeGap.div(2));
        }else {
          //set user.lastTakeTime as 15 days before now
          user.lastTakeTime = now - STATIC_CYCLE.mul(15);
        }


      } else {
        // Half return
        user.maxIncome = user.maxIncome.add(
          _calculateOutAmount(_amount)
        );

        //update lastTakeTime

        uint256 last = user.lastTakeTime;
        uint256 day = (now - last) / STATIC_CYCLE;
        if(day < 30) {

          uint256 timeGap = now - last;
          user.lastTakeTime = user.lastTakeTime.add(timeGap.div(3));
        }else {
          //set user.lastTakeTime as 15 days before now
          user.lastTakeTime = now - STATIC_CYCLE.mul(20);
        }
      }
      user.reinvest = true;
      user.deposit = user.deposit.add(_amount);

    } else {
      // Join out
      user.deposit = _amount;
      user.lastTakeTime = now;
      user.maxIncome = _calculateOutAmount(_amount);
      // Cumulative income cleared
      user.nodeIncome = 0;
      user.dayPoolIncome = 0;
      user.weekPoolIncome = 0;
      user.dynamicIncome = 0;
      burns[msg.sender].income = 0;
    }

    // Processing performance
    performances[msg.sender].wholeLine = performances[msg.sender]
    .wholeLine
    .add(_amount);
    _handlePerformance(user.referrer, _amount);
    // Processing node rewards
    _handleNodeReward(_amount);
    // Handling Node burn Reward
    _handleNodeBurnReward(msg.sender, _amount);
    // Processing node level
    _handleNodeLevel(user.referrer);
    // Handling prizes and draws
    _handlePool(user.referrer, _amount);

    // Technology founding team: 6%, manager by 14 managers
    for (uint8 i=0;i<14;i++) {
      founder[i]=founder[i].add(_amount.mul(6).div(100).div(14));
    }
    // Expansion operating expenses: 4%, manager by 13 managers
    for (uint8 i=0;i<13;i++) {
      operation[i]=operation[i].add(_amount.mul(4).div(100).div(13));
    }
    // Dex market making capital 4%, manager by 13 managers
    for (uint8 i=0;i<13;i++) {
      dex[i]=dex[i].add(_amount.mul(4).div(100).div(13));
    }

    // Insurance pool: 2%, divided into 10 pools
    for (uint8 i=0;i<10;i++) {

      if (i < 8) {//50% of Insurance fee assigned to the top 8 pools
        insurance[i] = insurance[i].add(_amount.mul(20).div(1000).div(16));
      }else{//50% of Insurance fee assigned to the last 2 pools
        insurance[i] = insurance[i].add(_amount.mul(20).div(1000).div(4));
      }

    }

    // Perpetual pool: 3%, manager by 13 managers
    for (uint8 i=0;i<13;i++) {
      sustainable[i]=sustainable[i].add(_amount.mul(30).div(1000).div(13));
    }

    //third party reward pool:3%
    thirdPool = thirdPool.add(_amount.mul(3).div(100));

    // Record the address of deposit 5,000
    if (user.deposit >= usdter.mul(5000)) {
      EnumerableSet.add(richman, msg.sender);
    }

    // Statistics total investment
    stats[msg.sender].investment = stats[msg.sender].investment.add(
      _amount
    );
    // Total revenue
    totalRevenue = totalRevenue.add(_amount);

    //Calculated floating staticRate when isFloatingStaticRate is true
    if(isFloatingStaticRate && staticRate >= 1 && staticRate < 100){
      _calcFloatingStaticRate();
    }

  }


  /**
   * @dev Calculated floating staticRate,When starting the insurance pool ,staticRate start floating. [0.01%-1%]
   */
  function _calcFloatingStaticRate() internal {
    if((now - yesFundPoolBal.updateTime) > DAY_POOL_CYCLE){
      uint256 _yesFundPoolBal = yesFundPoolBal.value;

      uint256 _nowFundPoolBal = usdt.balanceOf(address(this));
      uint256 minRate=1;//per ten thousand
      uint256 maxRate=100;//per ten thousand
      if (_yesFundPoolBal<=_nowFundPoolBal){
        uint256 riseBal= _nowFundPoolBal.sub(_yesFundPoolBal);
        if (riseBal>=_yesFundPoolBal.mul(10).div(100)) {
          if(staticRate < maxRate) {
            staticRate = staticRate.add(5);
          }else{
            staticRate = maxRate;
          }

        }
      }else {
        uint256 declineBal = _yesFundPoolBal.sub(_nowFundPoolBal);
        if (declineBal>=_yesFundPoolBal.mul(5).div(100)) {
          if(staticRate > 15) {
            staticRate = staticRate.sub(15);
          }else {
            staticRate = minRate;
          }

        }
      }

      //update yesFundPoolBal
      yesFundPoolBal.value= _nowFundPoolBal;
      yesFundPoolBal.updateTime=now;

    }

  }

  /**
   * @dev Burn tickets when you join
   */
  uint256 public joinBurnRate = 5;
  function _handleJoinBurn(address addr, uint256 _amount) internal {

    uint256 burnUsdt = _amount.mul(joinBurnRate).div(100);
    //ticket.price() return x ECO/USDT
    uint256 burnAmount = burnUsdt.mul(ticket.price()).div(usdter);
    uint256 bal = ticket.balanceOf(addr);

    if (bal >= burnAmount) {

      ticket.burnFromUsdt(addr, burnUsdt);

    } else {
      // USDT can be used to deduct tickets after the resonance of 2.8 million
      require(
        ticket.totalVending() >= uint256(1e18).mul(650000),
        "650K"
      );

      // Use USDT to deduct tickets
      usdt.safeTransferFrom(addr, address(ticket), burnUsdt);
      ticket.vendingAndBurn(addr,burnAmount);

    }
  }

  //_handleAirdrop(msg.sender, _amount);
  /**
   * @dev Airdro tickets when you join with 1000U
   */
  uint256 public airdropRate = 10;
  function _handleAirdrop(address addr, uint256 _amount) internal {

    uint256 airdropUsdt = _amount.mul(airdropRate).div(100);
    //ticket.price() return x ECO/USDT
    uint256 airdropAmount = airdropUsdt.mul(ticket.price()).div(usdter);


    ticket.airdrop(addr, airdropAmount);

    // Use USDT to deduct tickets
    //usdt.safeTransferFrom(addr, address(ticket), burnUsdt);

  }

  /**
   * @dev Receive revenue and calculate outgoing data
   */
  function take() public onlyJoined(msg.sender) {
    Account storage user = accounts[msg.sender];

    require(user.deposit > 0, "OUT");

    uint256 staticIncome = calculateStaticIncome(msg.sender);
    if (staticIncome > 0) {
      user.lastTakeTime =
      now -
      ((now - user.lastTakeTime) % STATIC_CYCLE);
      require(user.lastTakeTime < now,"lastTakeTime error");

    }

    uint256 paid = staticIncome
    .add(user.dynamicIncome)
    .add(user.nodeIncome)
    .add(burns[msg.sender].income);

    require(paid > 0);

    // Cleared
    user.nodeIncome = 0;
    user.dynamicIncome = 0;
    burns[msg.sender].income = 0;

    // Cumulative income
    user.income = user.income.add(paid);

    // Meet the exit conditions, or no re-investment and reach 1.3 times
    uint256 times13 = user.deposit.mul(13).div(10);
    bool special = !user.reinvest && user.income >= times13;
    // Out of the game
    if (user.income >= user.maxIncome || special) {
      // Deduct excess income
      if (special) {
        paid = times13.sub(user.income.sub(paid));
      } else {
        paid = paid.sub(user.income.sub(user.maxIncome));
      }
      // Data clear
      user.deposit = 0;
      user.income = 0;
      user.maxIncome = 0;
      user.reinvest = false;
    }

    // Static income returns to superior dynamic income
    // When zooming in half of the quota (including re-investment), dynamic acceleration is not provided to the upper 50 layers
    if (staticIncome > 0 && user.income < user.maxIncome.div(2)) {
      _handleDynamicIncome(msg.sender, staticIncome);
    }

    // Total income statistics
    stats[msg.sender].income = stats[msg.sender].income.add(paid);

    // USDT transfer
    _safeUsdtTransfer(msg.sender, paid);

    // Trigger
    _openWeekPool();
    _openDayPool();

    //Calculated floating staticRate when isFloatingStaticRate is true
    if(isFloatingStaticRate && staticRate >= 1 && staticRate < 100){
      _calcFloatingStaticRate();
    }
  }

  /**
   * @dev Receive insurance pool rewards
   */
  function takeReward() public {
    Account storage user = accounts[msg.sender];
    uint256 paid = user.reward;
    require(paid > 0);

    user.reward = 0;
    usdt.safeTransfer(msg.sender, paid);

    // Total income statistics
    stats[msg.sender].income = stats[msg.sender].income.add(paid);

    //Calculated floating staticRate when isFloatingStaticRate is true
    if(isFloatingStaticRate && staticRate >= 1 && staticRate < 100){
      _calcFloatingStaticRate();
    }
  }

  /**
   * @dev Receive prize pool income
   */
  function takePoolIncome() public {
    Account storage user = accounts[msg.sender];

    uint256 paid = user.dayPoolIncome.add(user.weekPoolIncome);
    require(paid > 0);

    user.dayPoolIncome = 0;
    user.weekPoolIncome = 0;

    // Total income statistics
    stats[msg.sender].income = stats[msg.sender].income.add(paid);

    _safeUsdtTransfer(msg.sender, paid);

    //Calculated floating staticRate when isFloatingStaticRate is true
    if(isFloatingStaticRate && staticRate >= 1 && staticRate < 100){
      _calcFloatingStaticRate();
    }
  }

  /**
   * @dev To activate Node burn, you need to destroy some tickets worth a specific USDT
   */
  function activateNodeBurn() public onlyJoined(msg.sender) {
    require(!burns[msg.sender].active, "ACT");

    uint256 burn = activateNodeBurnAmount();

    ticket.burnFromUsdt(msg.sender, burn);
    nodeBurnNumber++;

    burns[msg.sender].active = true;
  }

  /**
   * @dev Get the amount of USDT that activates the burned ticket for Node burn
   */
  function activateNodeBurnAmount() public pure returns (uint256) {

    return usdter.mul(3000);
  }

  /**
   * @dev Handling Node burn Reward
   */
  function _handleNodeBurnReward(address addr, uint256 _amount) internal {
    address referrer = accounts[addr].referrer;
    bool pioneer = false;

    while (referrer != address(0)) {
      AccountNodeBurn storage ap = burns[referrer];
      if (ap.active) {
        if (accounts[referrer].nodeLevel > 0) {
          uint256 paid;
          if (pioneer) {
            paid = _amount.mul(2).div(100); // 2%
          } else {
            paid = _amount.mul(5).div(100); // 5%
          }
          ap.income = ap.income.add(paid);
          break;
        } else if (!pioneer) {
          ap.income = ap.income.add(_amount.mul(3).div(100)); // 3%
          pioneer = true;
        }
      }
      referrer = accounts[referrer].referrer;
    }
  }

  /**
   * @dev Dealing with dynamic revenue,
   * @param _amount is staticIncome
   */
  function _handleDynamicIncome(address addr, uint256 _amount) internal {
    address account = accounts[addr].referrer;
    // Up to 50 layers
    for (uint8 i = 1; i <= 50; i++) {
      if (account == address(0)) {
        break;
      }

      Account storage user = accounts[account];
      if (user.deposit > 0 &&
        _canDynamicIncomeAble(performances[account].performance,i)
      ) {
        uint256 _income = _amount.mul(dynamicRates[i - 1]).div(1000);
        user.dynamicIncome = user.dynamicIncome.add(_income);
      }

      account = user.referrer;
    }
  }

  /**
   * @dev Judge whether you can get dynamic income
   */
  function _canDynamicIncomeAble(
    uint256 performance,
    uint8 floor
  ) internal pure returns (bool) {

    //floorLimit = performance/100
    uint256 floorLimit=performance.div(usdter).div(100);

    return floor <= floorLimit;

  }

  /**
   * @dev Process prize pool data and draw
   */
  function _handlePool(address referrer, uint256 _amount) internal {
    _openWeekPool();
    _openDayPool();

    uint256 prize = _amount.mul(2).div(100); // 2%

    uint256 dayPrize = prize.mul(60).div(100); // 60%
    uint256 weekPrize = prize.sub(dayPrize); // 40%

    _handleWeekPool(referrer, _amount, weekPrize);
    _handleDayPool(referrer, _amount, dayPrize);
  }

  /**
   * @dev Manually trigger the draw
   */
  function triggerOpenPool() public {
    _openWeekPool();
    _openDayPool();
  }

  /**
   * @dev Processing weekly prize pool
   */
  function _handleWeekPool(
    address referrer,
    uint256 _amount,
    uint256 _prize
  ) internal {
    Pool storage week = weekPool[weekPoolId];

    week.amount = week.amount.add(_prize);
    week.values[referrer] = week.values[referrer].add(_amount);// add referrer Performance
    _PoolSort(week, referrer, 4);
  }

  /**
   * @dev Handling the daily prize pool
   */
  function _handleDayPool(
    address referrer,
    uint256 _amount,
    uint256 _prize
  ) internal {
    Pool storage day = dayPool[dayPoolId];

    day.amount = day.amount.add(_prize);
    day.values[referrer] = day.values[referrer].add(_amount);
    _PoolSort(day, referrer, 4);
  }

  /**
   * @dev Prize pool sorting
   */
  function _PoolSort(
    Pool storage pool,
    address addr,
    uint8 number
  ) internal {
    for (uint8 i = 0; i < number; i++) {
      address key = pool.ranks[i];
      if (key == addr) {
        break;
      }
      if (pool.values[addr] > pool.values[key]) {
        for (uint8 j = number; j > i; j--) {
          pool.ranks[j] = pool.ranks[j - 1];
        }
        pool.ranks[i] = addr;

        for (uint8 k = i + 1; k < number; k++) {
          if (pool.ranks[k] == addr) {
            for (uint8 l = k; l < number; l++) {
              pool.ranks[l] = pool.ranks[l + 1];
            }
            break;
          }
        }
        break;
      }
    }
  }

  /**
   * @dev Weekly prize pool draw
   */
  function _openWeekPool() internal {
    Pool storage week = weekPool[weekPoolId];
    // Determine whether the weekly prize pool can draw prizes
    if (now >= week.date + WEEK_POOL_CYCLE) {
      weekPoolId++;
      weekPool[weekPoolId].date = now;

      // 10% for the draw
      uint256 prize = week.amount.mul(10).div(100);
      // 90% naturally rolled into the next round
      weekPool[weekPoolId].amount = week.amount.sub(prize);

      if (prize > 0) {
        // No prizes left
        uint256 surplus = prize;

        // Proportion 55%、25%、15%、5%
        uint256[4] memory rates = [
        uint256(55),
        uint256(25),
        uint256(15),
        uint256(5)
        ];
        // Top 4
        for (uint8 i = 0; i < 4; i++) {
          address addr = week.ranks[i];
          uint256 reward = prize.mul(rates[i]).div(100);

          // Reward for rankings, and rollover to the next round without rankings
          if (addr != address(0)) {
            accounts[addr].weekPoolIncome = accounts[addr]
            .weekPoolIncome
            .add(reward);
            surplus = surplus.sub(reward);
          }
        }

        // Add the rest to the next round when addr != address(0)
        weekPool[weekPoolId].amount = weekPool[weekPoolId].amount.add(
          surplus
        );
      }
    }
  }

  /**
   * @dev Daily prize pool draw
   */
  function _openDayPool() internal {
    Pool storage day = dayPool[dayPoolId];
    // Determine whether the daily prize pool can be drawn
    if (now >= day.date + DAY_POOL_CYCLE) {
      dayPoolId++;
      dayPool[dayPoolId].date = now;

      // 10% for the draw
      uint256 prize = day.amount.mul(10).div(100);
      // 90% naturally rolled into the next round
      dayPool[dayPoolId].amount = day.amount.sub(prize);

      if (prize > 0) {
        // No prizes left
        uint256 surplus = prize;

        // ratios 55%、25%、15%、5%
        uint256[4] memory rates = [
        uint256(55),
        uint256(25),
        uint256(15),
        uint256(5)
        ];

        // Top 4
        for (uint8 i = 0; i < 4; i++) {
          address addr = day.ranks[i];
          uint256 reward = prize.mul(rates[i]).div(100);

          // Reward for rankings, and rollover to the next round without rankings
          if (addr != address(0)) {
            accounts[addr].dayPoolIncome = accounts[addr]
            .dayPoolIncome
            .add(reward);
            surplus = surplus.sub(reward);
          }
        }


        // Add the rest to the next round
        dayPool[dayPoolId].amount = dayPool[dayPoolId].amount.add(
          surplus
        );
      }
    }
  }

  /**
   * @dev Processing account performance
   */
  function _handlePerformance(address referrer, uint256 _amount) internal {
    // Direct performance
    performances[referrer].performance = performances[referrer]
    .performance
    .add(_amount);
    // Full line performance
    address addr = referrer;
    while (addr != address(0)) {
      performances[addr].wholeLine = performances[addr].wholeLine.add(
        _amount
      );
      addr = accounts[addr].referrer;
    }
  }

  /**
   * @dev Processing node level
   */
  function _handleNodeLevel(address referrer) internal {
    address addr = referrer;

    // Condition
    uint256[4] memory c1s = [
    usdter.mul(100000),
    usdter.mul(300000),
    usdter.mul(600000),
    usdter.mul(1200000)
    ];
    uint256[4] memory c2s = [
    usdter.mul(250000),
    usdter.mul(600000),
    usdter.mul(1200000),
    usdter.mul(2250000)
    ];
    uint256[4] memory s1s = [
    usdter.mul(20000),
    usdter.mul(60000),
    usdter.mul(90000),
    usdter.mul(160000)
    ];
    uint256[4] memory s2s = [
    usdter.mul(30000),
    usdter.mul(90000),
    usdter.mul(135000),
    usdter.mul(240000)
    ];

    while (addr != address(0)) {
      uint8 level = accounts[addr].nodeLevel;
      if (level < 4) {
        uint256 c1 = c1s[level];
        uint256 c2 = c2s[level];

        if (now - accounts[addr].joinTime <= NODE_DISCOUNT_TIME) {
          c1 = c1.sub(s1s[level]);
          c2 = c2.sub(s2s[level]);
        }

        if (_handleNodeLevelUpgrade(addr, c1, c2)) {
          accounts[addr].nodeLevel = level + 1;
          nodes[level + 1].push(addr);
        }
      }

      addr = accounts[addr].referrer;
    }
  }

  /**
   * @dev Determine whether the upgrade conditions are met according to the conditions
   */
  function _handleNodeLevelUpgrade(
    address addr,
    uint256 c1,
    uint256 c2
  ) internal view returns (bool) {
    uint8 count = 0;
    uint256 min = uint256(-1);

    for (uint256 i = 0; i < teams[addr].length; i++) {
      uint256 w = performances[teams[addr][i]].wholeLine;

      // Case 1
      if (w >= c1) {
        count++;
        if (count >= 3) {
          return true;
        }
      }

      // Case 2
      if (w >= c2 && w < min) {
        min = w;
      }
    }
    if (min < uint256(-1) && performances[addr].wholeLine.sub(min) >= c2) {
      return true;
    }

    return false;
  }

  /**
   * @dev Processing node rewards
   */
  function _handleNodeReward(uint256 _amount) internal {
    uint256 reward = _amount.mul(3).div(100);
    for (uint8 i = 1; i <= 4; i++) {
      address[] storage _nodes = nodes[i];
      uint256 len = _nodes.length;
      if (len > 0) {
        uint256 _reward = reward.div(len);
        for (uint256 j = 0; j < len; j++) {
          Account storage user = accounts[_nodes[j]];
          user.nodeIncome = user.nodeIncome.add(_reward);
        }
      }
    }
  }

  /**
   * @dev Calculate static income
   */
  function calculateStaticIncome(address addr) public view returns (uint256) {
    Account storage user = accounts[addr];
    if (user.deposit > 0 && user.lastTakeTime > 0 && user.lastTakeTime < 70000000000) {
      uint256 last = user.lastTakeTime;
      uint256 day = (now - last) / STATIC_CYCLE;

      if (day == 0) {
        return 0;
      }

      if (day > 30) {
        day = 30;
      }

      return user.deposit.mul(staticRate).div(10000).mul(day);
    }
    return 0;
  }

  /**
   * @dev Calculate out multiple
   */
  function _calculateOutAmount(uint256 _amount)
  internal
  pure
  returns (uint256)
  {
    if (_amount >= usdter.mul(15000)) {
      return _amount.mul(40).div(10);
    } else if (_amount >= usdter.mul(5000)) {
      return _amount.mul(35).div(10);
    } else if (_amount >= usdter.mul(1000)) {
      return _amount.mul(30).div(10);
    } else {
      return _amount.mul(25).div(10);
    }
  }

  /**
   * @dev Calculate the out multiple of all reinvestments
   */
  function _calculateFullOutAmount(uint256 _amount)
  internal
  pure
  returns (uint256)
  {
    if (_amount >= usdter.mul(15000)) {
      return _amount.mul(50).div(10);
    } else if (_amount >= usdter.mul(5000)) {
      return _amount.mul(45).div(10);
    } else if (_amount >= usdter.mul(1000)) {
      return _amount.mul(40).div(10);
    } else {
      return _amount.mul(30).div(10);
    }
  }

  /**
   * @dev Get the number of nodes at a certain level
   */
  function nodeLength(uint8 level) public view returns (uint256) {
    return nodes[level].length;
  }

  /**
   * @dev Number of teams
   */
  function teamsLength(address addr) public view returns (uint256) {
    return teams[addr].length;
  }

  /**
   * @dev Daily prize pool ranking
   */
  function dayPoolRank(uint64 _id, uint8 _rank)
  public
  view
  returns (address)
  {
    return dayPool[_id].ranks[_rank];
  }

  /**
   * @dev Daily prize pool performance
   */
  function dayPoolValue(uint64 _id, address _addr)
  public
  view
  returns (uint256)
  {
    return dayPool[_id].values[_addr];
  }

  /**
   * @dev Weekly prize pool ranking
   */
  function weekPoolRank(uint64 _id, uint8 _rank)
  public
  view
  returns (address)
  {
    return weekPool[_id].ranks[_rank];
  }

  /**
   * @dev Weekly prize pool performance
   */
  function weekPoolValue(uint64 _id, address _addr)
  public
  view
  returns (uint256)
  {
    return weekPool[_id].values[_addr];
  }

  /**
   * @dev Team statistics, return the smallest, medium and most performance
   */
  function teamsStats(address addr) public view returns (uint256, uint256) {
    uint256 count = teams[addr].length;
    if (count > 0) {
      uint256 max = performances[teams[addr][count - 1]].wholeLine;
      uint256 min = performances[teams[addr][count - 1]].wholeLine;
      for (uint256 i = 0; i < count; i++) {
        if (performances[teams[addr][i]].wholeLine > max) {
          max = performances[teams[addr][i]].wholeLine;
        }
        if (performances[teams[addr][i]].wholeLine < min) {
          min = performances[teams[addr][i]].wholeLine;
        }
      }

      return (max, min);
    }
    return (0, 0);
  }

  /**
   * @dev Count how many people meet the conditions
   */
  function teamsCount(address addr, uint256 _amount)
  public
  view
  returns (uint256)
  {
    uint256 count;

    for (uint256 i = 0; i < teams[addr].length; i++) {
      if (_amount <= performances[teams[addr][i]].wholeLine) {
        count++;
      }
    }

    return count;
  }

  /**
   * @dev Get the number of large account addresses
   */
  function richmanLength() public view returns (uint256) {
    return EnumerableSet.length(richman);
  }

  /**
   * @dev Safe USDT transfer, excluding the balance of insurance pool and perpetual pool
   */
  function _safeUsdtTransfer(address addr, uint256 _amount) internal {
    uint256 bal = usdt.balanceOf(address(this));
    uint256 totalSustainable;
    uint256 totalInsurance;
    for (uint256 i =0; i<13;i++) {
      totalSustainable =totalSustainable.add(sustainable[i]);
    }
    for (uint256 i =0; i<10;i++) {
      totalInsurance = totalInsurance.add(insurance[i]);
    }
    bal = bal.sub(totalInsurance).sub(totalSustainable);

    if (bal < _amount) {
      usdt.safeTransfer(addr, bal);
    } else {
      usdt.safeTransfer(addr, _amount);
    }
  }

  /**
   * @dev Activate the insurance pool, only the managers can call
   */
  function activeInsurance(uint256 _steps) public onlyManagers(msg.sender) {
    require(_steps > 0 && _steps <= 10,"steps exceeds 10");

    uint256 nodePaid = insurance[_steps - 1].mul(30).div(100);
    uint256 bigPaid = insurance[_steps - 1].sub(nodePaid);

    insurance[_steps - 1] = 0;

    // Issued to richman
    uint256 _richmanLen = EnumerableSet.length(richman);
    uint256 _lenPerBatch = _richmanLen.div(10);

    if (_richmanLen > 0) {
      if(_richmanLen < 10) {
        uint256 paid = bigPaid.div(_richmanLen);
        for (uint256 i = 0; i < _richmanLen; i++) {
          Account storage user = accounts[EnumerableSet.at(richman, i)];
          user.reward = user.reward.add(paid);
        }
      }else {
        if(_lenPerBatch > 0){
          //uint256 _remainder = _richmanLen.sub(_richmanLen.div(10).mul(10));
          uint256 _remainder = _richmanLen.mod(10);
          uint256 _startIndex = _lenPerBatch.mul(_steps - 1).add(_remainder);
          uint256 _endIndex = _lenPerBatch.mul(_steps).add(_remainder);
          uint256 paid = bigPaid.div(_lenPerBatch);
          if(_steps==1) {
            _startIndex = 0;
            uint256 _firstBatchLen=_endIndex.sub(_startIndex);
            paid = bigPaid.div(_firstBatchLen);
          }else if(_steps==10) {
            _endIndex = _richmanLen;

          }

          for (uint256 i = _startIndex; i < _endIndex; i++) {
            Account storage user = accounts[EnumerableSet.at(richman, i)];
            user.reward = user.reward.add(paid);
          }
        }
      }


    }

    // Issued to node
    uint256[4] memory _rates = [
    uint256(10),
    uint256(20),
    uint256(30),
    uint256(40)
    ];
    for (uint8 i = 1; i <= 4; i++) {
      uint256 _nodeLen = nodes[i].length;
      if (_nodeLen > 0) {
        uint256 paid = nodePaid.mul(_rates[i - 1]).div(100).div(
          _nodeLen
        );
        for (uint256 j = 0; j < _nodeLen; j++) {
          Account storage user = accounts[nodes[i][j]];
          user.reward = user.reward.add(paid);
        }
      }
    }

  }

  /**
   * @dev close floating flag, only the managers can call
   */
  function setFloatingFlag() public onlyManagers(msg.sender) {
    bool _nowFlag = isFloatingStaticRate;
    //set reverse flag
    isFloatingStaticRate = !_nowFlag;

    //set yesFundPoolBalance
    yesFundPoolBal.value=usdt.balanceOf(address(this));
    yesFundPoolBal.updateTime=now;

  }



  /**
   * @dev Transfer to the perpetual pool, only the managers can call
   */
  function activeSustainable(address next) public onlyManagers(msg.sender) {
    uint256 paid = 0;
    uint256 index = managers[msg.sender].weightId;

    require(index > 0 && index <= 13 && sustainable[index - 1] > 0);//index <= 13

    paid = sustainable[index - 1];
    sustainable[index - 1] = 0;

    uint256 bal = usdt.balanceOf(address(this));
    if (bal < paid) {
      usdt.safeTransfer(next, bal);
    } else {
      usdt.safeTransfer(next, paid);
    }
  }

  /**
   * @dev Set join-burn rate of return, only the managers can call
   */
  function setJoinBurnRate(uint256 _joinBurnRate) public onlyManagers(msg.sender) {
    require(_joinBurnRate <= 100);
    joinBurnRate = _joinBurnRate;
  }

  /**
   * @dev Set airdrop rate of return, only the managers can call
   */
  function setAirdropRate(uint256 _airdropRate) public onlyManagers(msg.sender) {
    require(_airdropRate <= 100);
    airdropRate = _airdropRate;
  }

  /**
   * @dev Set static rate of return, only the managers can call
   */
  function setStaticRate(uint256 _rate) public onlyManagers(msg.sender) {
    require(_rate <= 10000);
    staticRate = _rate;
  }

  /**
   * @dev Set dynamic rate of return, only the managers can call
   */
  function setDynamicRates(uint8 level, uint256 _rate) public onlyManagers(msg.sender) {
    require(level < 50);
    require(_rate <= 1000);
    dynamicRates[level] = _rate;
  }

  /**
   * @dev Set up the ticket contract, only the managers can call
   */
  function setMaxInvestAmount(uint256 _maxAmount) public onlyManagers(msg.sender) {
    maxInvestAmount = _maxAmount;
  }

  /**
   * @dev Set up the ticket contract, only the administrator can call
   */
  function setTicket(ITicketsToken _ticket) public onlyOwner {
    ticket = _ticket;
  }

  /**
   * @dev Set up manages addresses, only the administrator can call
   */
  address[] public managerAddrs;
  function setManagers(address _manager) public onlyOwner {
    require(managerAddrs.length < 14,"managers are full");
    require(!managers[_manager].isManager,"_manager is already a manager");

    managerAddrs.push(_manager);
    managers[_manager].isManager = true;
    managers[_manager].weightId = uint8(managerAddrs.length);

  }

  /**
   * @dev Return the length of managers
   */
  function mangersLen() public view returns(uint256){
    return managerAddrs.length;
  }

  /**
   * @dev set new maxInvestAmountPerDay,_amountLimit need *1e6
   */
  function setMaxInvestAmountPerDay(uint256 _amountLimit) public onlyManagers(msg.sender) {
    require(_amountLimit <= 1e18,"ANR");
    maxInvestAmountPerDay = _amountLimit;
  }

  /**
   * @dev Receive the third pool reward, only the managers can call
   */
  function takeThirdPool(address _addr1,address _addr2,address _addr3) public onlyManagers(msg.sender) {

    uint256 paid = 0;

    require(thirdPool > 0,'thirdPool must GT 0');
    paid = thirdPool.div(3);
    thirdPool = 0;

    usdt.safeTransfer(_addr1, paid);
    usdt.safeTransfer(_addr2, paid);
    usdt.safeTransfer(_addr3, paid);


  }

  /**
   * @dev Receive the technical founding team, only the managers can call
   */
  function takeFounder(address _addr) public onlyManagers(msg.sender) {

    uint256 paid = 0;
    uint256 index = managers[msg.sender].weightId;

    require(index > 0 && index <= 14 && founder[index - 1] > 0);//index <= 14
    paid = founder[index - 1];
    founder[index - 1] = 0;

    usdt.safeTransfer(_addr, paid);

  }

  /**
   * @dev Receive expansion operation fee, only the managers can call
   */
  function takeOperation(address _addr) public onlyManagers(msg.sender) {
    uint256 paid = 0;
    uint256 index = managers[msg.sender].weightId;

    require(index > 0 && index <= 13 && operation[index - 1] > 0);//index <= 13
    paid = operation[index - 1];
    operation[index - 1] = 0;

    usdt.safeTransfer(_addr, paid);

  }

  /**
   * @dev Receive dex fee, only the managers can call
   */
  function takeDex(address _addr) public onlyManagers(msg.sender) {
    uint256 paid = 0;
    uint256 index = managers[msg.sender].weightId;

    require(index > 0 && index <= 13 && dex[index - 1] > 0);//index <= 13
    paid = dex[index - 1];
    dex[index - 1] = 0;

    usdt.safeTransfer(_addr, paid);

  }

  /**
   * @dev Withdrawal non-USDT token, only the managers can call
   */
  function withdrawalToken(address _tokenAddress) onlyOwner public {
    require(_tokenAddress != address(usdt),'Cannot withdrawal USDT directly');
    IERC20 token = IERC20(_tokenAddress);
    token.safeTransfer(msg.sender, token.balanceOf(address(this)));
  }
  /**
   * @dev get yesterday fund pool balance
   */
  function getBalAndRate() public view returns(uint256 _yesBal,uint256 _nowBal,uint256 _staticRate) {

    return (yesFundPoolBal.value,usdt.balanceOf(address(this)),staticRate);
  }

  function dayWeekData1(address _addr) public view
  returns(
    uint256 _dayPoolId,uint256 _weekPoolId,uint256 _dayPoolAmount,
    uint256 _dayPoolDate,uint256 _weekPoolAmount,uint256 _weekPoolDate,
    uint256 _staticIncome,uint256 _paid,bool _bo
  )
  {
    _dayPoolId = dayPoolId;
    _weekPoolId = weekPoolId;

    _dayPoolAmount = dayPool[dayPoolId].amount;
    _dayPoolDate = dayPool[dayPoolId].date;
    _weekPoolAmount = weekPool[weekPoolId].amount;
    _weekPoolDate = weekPool[weekPoolId].date;

    Account storage user = accounts[_addr];
    _staticIncome = calculateStaticIncome(_addr);

    _paid = _staticIncome
    .add(user.dynamicIncome)
    .add(user.nodeIncome)
    .add(burns[_addr].income)
    .add(user.income);

    _bo =user.deposit>0 && !user.reinvest && _paid >= user.deposit;



  }

  function dayWeekData34(address _addr) public view
  returns(
    uint256 _directPerf,uint256 _wholeLine,address _dayChampAddr,uint256 _dayChampIncome,
    uint256 _dayChampPerf,address _daySecondAddr,address _dayThirdAddr,address _weekChampAddr,
    uint256 _weekChampIncome,uint256 _weekChampPerf,address _weekSecondAddr,uint256 _weekSecondIncome,
    address _maxDepositAddr
  )
  {
    _directPerf = performances[_addr].performance;
    _wholeLine = performances[_addr].wholeLine;

    _dayChampAddr = dayPool[dayPoolId].ranks[0];
    _dayChampPerf = dayPool[dayPoolId].values[_dayChampAddr];
    _dayChampIncome = dayPool[dayPoolId].amount.mul(55).div(100);

    _daySecondAddr = dayPool[dayPoolId].ranks[1];
    _dayThirdAddr = dayPool[dayPoolId].ranks[2];

    if (weekPoolId >0) {
      _weekChampAddr = weekPool[weekPoolId-1].ranks[0];
      _weekChampPerf = weekPool[weekPoolId-1].values[_weekChampAddr];
      _weekChampIncome = weekPool[weekPoolId-1].amount.mul(55).div(100);

      _weekSecondAddr = weekPool[weekPoolId-1].ranks[1];
      _weekSecondIncome = weekPool[weekPoolId-1].amount.mul(25).div(100);
    }

    _maxDepositAddr = weekPool[weekPoolId].ranks[0];

  }

  function dayWeekData56(address _addr) public view
  returns(
    uint256 _createdAt,uint256 _insurance,uint256 _sustainable,
    uint256 _max,uint256 _min,uint256 _nodeIncome,uint256 _nodeBurnIncome,uint256 _untakeIncome
  )
  {
    Account storage user = accounts[_addr];
    _createdAt = createdAt;
    for (uint256 i =0; i<10;i++) {
      _insurance =_insurance.add(insurance[i]);
    }
    for (uint256 i =0; i<13;i++) {
      _sustainable =_sustainable.add(sustainable[i]);
    }
    //_sustainable = sustainable1.add(sustainable2).add(sustainable3);
    (_max,_min) = teamsStats(_addr);
    _nodeIncome = user.nodeIncome;
    _nodeBurnIncome = burns[_addr].income;
    uint256 _dynamicIncome = user.dynamicIncome;
    uint256 _staticIncome = calculateStaticIncome(_addr);
    _untakeIncome = _dynamicIncome.add(_staticIncome).add(_nodeBurnIncome).add(_nodeIncome);

  }

}