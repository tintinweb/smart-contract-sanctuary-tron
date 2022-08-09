//SourceUnit: VaultFactory-full.sol


// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

// File: interfaces/IVault.sol

interface IVault {

    function init(address _merchant) external;

    // function withdrawFee(address[] calldata tokens,uint[] calldata fees) external;

    // function addAuditor(address auditor) external;

    // function removeAuditor(address auditor) external;

    // function setAuditorPeriodLimit(address auditor,address token, uint periodLimit) external;

    function transferMerchant(address _merchant) external;

    function pause() external;

    function unpause() external;
}
// File: interfaces/IVaultFactory.sol

interface IVaultFactory {

    function isSystemAuditor(address account) external view returns(bool);

    function isPlatformAuditor(address account) external view returns(bool);

    function WETH() external view returns(address);

    function periodDuration() external view returns(uint);

    // function cfo() external view returns(address);

    function feeTo() external view returns(address);

    function allVaultPaused() external view returns(bool);

    function updateAuditorAuthorized(address auditor,address token,uint amount) external returns(bool);
}
// File: libs/EvmAddress.sol

library EvmAddress {
    function toEvmAddress(address adddr) internal pure returns(address){
        return address(uint160(adddr));
    }

    function convertAddresses(address[] memory addrs) internal pure returns(address[] memory){
        address[] memory evmAddrs = new address[](addrs.length);
        for(uint i=0;i<addrs.length;i++){
            evmAddrs[i] = toEvmAddress(addrs[i]);
        }        

        return evmAddrs;
    }    
}
// File: libs/IWETH.sol

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: libs/TransferHelper.sol



pragma solidity ^0.8.0;

library TransferHelper {
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}
// File: libs/ChainId.sol

/// @title Function for getting the current chain ID
library ChainId {
    /// @dev Gets the current chain ID
    /// @return chainId The current chain ID
    function get() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}
// File: libs/PayHelper.sol

library PayHelper {
    using EvmAddress for address;

    bytes32 private constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chain,address verifyingContract)");
    bytes32 private constant SetAuditorStatusTypeHash = keccak256("SetAuditorStatus(address auditor,bool enableStatus,uint256 rand)");
    bytes32 private constant SetAuditorPeriodLimitsTypeHash = keccak256("SetAuditorPeriodLimits(address auditor,address[] tokens,uint256[] periodLimits,uint256 rand)");
    bytes32 private constant AddAuditorAndSetPeriodLimitsTypeHash = keccak256("AddAuditorAndSetPeriodLimits(address auditor,address[] tokens,uint256[] periodLimits,uint256 rand)");
    
    function auditorTokenKey(address auditor,address token) internal pure returns(bytes32){
        return keccak256(abi.encode(auditor.toEvmAddress(),token.toEvmAddress()));
    }

    function toUint8(bytes32 n) internal pure returns(uint8){
        require(uint(n) < type(uint8).max,"n exceeds 8 bits");
        return uint8(uint(n));
    }

    function periodStart(uint _utcTime,uint _periodDuration) internal pure returns(uint){
        uint utcPeriodStart = _utcTime - (_utcTime % _periodDuration);

        return utcPeriodStart - _periodDuration;
    }

    function recoverSetAuditorStatusSign(bytes32 nameHash,address auditor,bool enableStatus,uint rand,uint8 v,bytes32 r,bytes32 s) internal view returns(address){
        bytes32 structHash = keccak256(abi.encode(SetAuditorStatusTypeHash, auditor, enableStatus, rand));
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, nameHash, ChainId.get(), address(this).toEvmAddress()));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0),"invalid signature");

        return signatory.toEvmAddress();
    }

    function recoverSetAuditorPeriodLimitsSign(bytes32 nameHash,address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) internal view returns(address){
        return _recoverSetAuditorPeriodLimitsSign(nameHash,auditor,tokens,periodLimits,rand,v,r,s,false);
    }

    function recoverAddAuditorAndSetPeriodLimitsSign(bytes32 nameHash,address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) internal view returns(address){
        return _recoverSetAuditorPeriodLimitsSign(nameHash,auditor,tokens,periodLimits,rand,v,r,s,true);
    }

    function _recoverSetAuditorPeriodLimitsSign(bytes32 nameHash,address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s,bool withEnableAuditor) internal view returns(address){
        bytes32 typeHash = withEnableAuditor ? AddAuditorAndSetPeriodLimitsTypeHash : SetAuditorPeriodLimitsTypeHash;
        bytes32 structHash = keccak256(abi.encode(
            typeHash,
            auditor,
            keccak256(abi.encodePacked(tokens)),
            keccak256(abi.encodePacked(periodLimits)),
            rand
        ));
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, nameHash, ChainId.get(), address(this).toEvmAddress()));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0),"invalid signature");

        return signatory.toEvmAddress();
    }
}
// File: libs/ReentrancyGuard.sol

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: libs/SafeMath.sol

// File: @openzeppelin/contracts/math/SafeMath.sol
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// File: libs/Address.sol

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
// File: libs/IERC20.sol

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
// File: libs/SafeERC20.sol

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: libs/Context.sol

// File: @openzeppelin/contracts/GSN/Context.sol
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// File: libs/Pausable.sol

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
    function _pause() internal virtual whenNotPaused {
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
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: Vault.sol

// import '../libs/Address.sol';

contract Vault is Pausable,ReentrancyGuard,IVault {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EvmAddress for address;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chain,address verifyingContract)");
    bytes32 public constant WITHDRAW_TYPEHASH = keccak256("Withdraw(uint256 withdrawType,address account,address token,uint256 amount,uint256 rand)");
    bytes32 public constant vaultNameHash = keccak256("PayVault");

    mapping(bytes32 => uint256) public auditorPeriodLimitOf;
    mapping(bytes32 => mapping(uint256 => uint256)) public periodAuthorizedOf;
    mapping(address => bool) public isAuditor;

    mapping(uint256 => bool) public isUsedRand;

    address public immutable factory;
    address public merchant;

    bool private _isInited;

    event AuditorPeriodLimitChanged(address auditor,address token,uint oldLimit,uint newLimit,uint timestamp);
    event Withdrawn(uint withdrawType,address auditor,address systemAuditor,address account, address token,uint amount,uint[] rands,uint timestamp);
    event AuditorStatusChanged(address caller,address auditor,bool status,uint timestamp);
    event MerchantTransfered(address oldMerchant,address newMerchant);

    modifier onlyFactory {
        require(msg.sender == factory,"onlyFactory: forbidden");
        _;
    }

    modifier checkAndUseRand(uint rand) {
        require(rand > 0,"rand can not be 0");
        require(!isUsedRand[rand],"rand used");
        isUsedRand[rand] = true;
        _;
    }

    constructor(){        
        factory = msg.sender;
    }

    receive() external payable {
        IWETH(IVaultFactory(factory).WETH()).deposit{value : msg.value}();
    }

    function init(address _merchant) external override onlyFactory {
        _merchant = _merchant.toEvmAddress();
        require(_merchant!=address(0),"merchant can not be address 0");
        require(!_isInited,"inited");
        _isInited = true;
        merchant = _merchant;

        emit MerchantTransfered(address(0),_merchant);
    }

    //withdrawType: 0-merchantWithdraw,1-merchantUserWithdraw,2-agentWithdraw,3-withdrawFee
    //signRsvs[0]: auditor sign V
    //signRsvs[1]: auditor sign R
    //signRsvs[2]: auditor sign S
    //signRsvs[3]: system sign V
    //signRsvs[4]: system sign R
    //signRsvs[5]: system sign S
    function withdraw(uint withdrawType,address account,address token,uint amount,uint[] calldata rands,bytes32[] calldata signRsvs) external checkAndUseRand(rands[0]) checkAndUseRand(rands[1]) whenNotPaused nonReentrant {
        account = account.toEvmAddress();
        token = token.toEvmAddress();
        require(withdrawType != 0 || account == merchant,"account must be merchant");
        require(withdrawType != 3 || account == IVaultFactory(factory).feeTo(),"account must be feeTo");
        require(account != address(0),"account can not be address 0");
        require(token != address(0),"token can not be address 0");
        require(amount > 0,"amount can not be address 0");
        require(!IVaultFactory(factory).allVaultPaused(),"all vault paused");

        address auditor = recoverWithdrawSign(withdrawType,account,token,amount,rands[0],PayHelper.toUint8(signRsvs[0]),signRsvs[1],signRsvs[2]);
        require(auditor != address(0),"invalid auditor signature");
        if(withdrawType == 1){
            require(isAuditor[auditor],"auditor unauthorized");
        }else{
            require(IVaultFactory(factory).isPlatformAuditor(auditor),"auditor unauthorized");
        }
        
        address systemAuditor = recoverWithdrawSign(withdrawType,account,token,amount,rands[1],PayHelper.toUint8(signRsvs[3]),signRsvs[4],signRsvs[5]);
        require(systemAuditor != address(0),"invalid system signature");
        require(IVaultFactory(factory).isSystemAuditor(systemAuditor),"system unauthorized");

        if(withdrawType == 1){
            _updateAuditorAuthorized(auditor,token,amount);
        }else{
            require(IVaultFactory(factory).updateAuditorAuthorized(auditor,token,amount),"factory update auditor authorized failed");
        }

        _transferToken(token, account, amount);

        emit Withdrawn(withdrawType,auditor,systemAuditor,account,token,amount,rands,block.timestamp);
    }

    function recoverWithdrawSign(uint withdrawType,address account,address token,uint amount,uint rand,uint8 v,bytes32 r,bytes32 s) public view returns(address){

        account = account.toEvmAddress();
        token = token.toEvmAddress();

        bytes32 structHash = keccak256(abi.encode(WITHDRAW_TYPEHASH, withdrawType, account, token, amount, rand));
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, vaultNameHash, ChainId.get(), address(this).toEvmAddress()));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);

        return signatory.toEvmAddress();
    }

    function _updateAuditorAuthorized(address auditor,address token,uint amount) internal {
        bytes32 key = PayHelper.auditorTokenKey(auditor, token);
        uint periodKey = PayHelper.periodStart(block.timestamp,IVaultFactory(factory).periodDuration());
        uint authorizedAmount = periodAuthorizedOf[key][periodKey];
        require(authorizedAmount.add(amount) <= auditorPeriodLimitOf[key],"exceeds auditor period limit");
        
        periodAuthorizedOf[key][periodKey] = periodAuthorizedOf[key][periodKey].add(amount);
    }

    function _transferToken(address token,address to,uint amount) internal {
        address weth = IVaultFactory(factory).WETH();
        if(token == weth){
            IWETH(weth).withdraw(amount);
            TransferHelper.safeTransferETH(to, amount);
        }else{
            IERC20(token).safeTransfer(to,amount);
        }
    }

    function setAuditorStatus(address auditor,bool enableStatus,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();
        
        address signatory = PayHelper.recoverSetAuditorStatusSign(vaultNameHash, auditor, enableStatus, rand, v, r, s);
        require(signatory == merchant,"unauthorized");
        
        _setAuditorStatus(auditor,enableStatus);
    }

    function _setAuditorStatus(address auditor,bool enableStatus) internal {
        require(auditor != address(0),"auditor can not be address 0");
        isAuditor[auditor] = enableStatus;
        emit AuditorStatusChanged(msg.sender,auditor,enableStatus,block.timestamp);
    }

    function setAuditorPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();
        tokens = EvmAddress.convertAddresses(tokens);

        address signatory = PayHelper.recoverSetAuditorPeriodLimitsSign(vaultNameHash, auditor, tokens, periodLimits, rand, v, r, s);
        require(signatory == merchant,"unauthorized");

       _setAuditorPeriodLimits(auditor,tokens,periodLimits);
    }

    function _setAuditorPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits) internal {
        require(auditor != address(0),"auditor can not be address 0");
        require(tokens.length > 0,"tokens can not be empty");
        require(tokens.length == periodLimits.length,"length of periodLimits must equals to length of tokens");
        require(isAuditor[auditor],"invalid auditor");

        for(uint i=0;i<tokens.length;i++){
            require(tokens[i] != address(0),"included token address 0");
            bytes32 key = PayHelper.auditorTokenKey(auditor,tokens[i]);
            uint old = auditorPeriodLimitOf[key];
            auditorPeriodLimitOf[key] = periodLimits[i];

            emit AuditorPeriodLimitChanged(auditor,tokens[i],old,periodLimits[i],block.timestamp);
        }
    }

    function addAuditorAndSetPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();
        tokens = EvmAddress.convertAddresses(tokens);

        address signatory = PayHelper.recoverAddAuditorAndSetPeriodLimitsSign(vaultNameHash, auditor, tokens, periodLimits, rand, v, r, s);
        require(signatory == merchant,"unauthorized");

        _setAuditorStatus(auditor, true);
       _setAuditorPeriodLimits(auditor,tokens,periodLimits);
    }

    // function withdrawFee(address[] calldata tokens,uint[] calldata fees) external {
    //     require(tokens.length > 0,"tokens can not be empty");
    //     require(fees.length == tokens.length,"invalid fees length");
    //     address feeTo = IVaultFactory(factory).feeTo();
    //     require(feeTo != address(0),"feeTo not setted");
    //     require(msg.sender == IVaultFactory(factory).cfo());

    //     for(uint i=0;i<tokens.length;i++){
    //         require(tokens[i] != address(0),"included address 0 token");
    //         require(fees[i] > 0,"included 0 fee");
    //         _transferToken(tokens[i], feeTo, fees[i]);
    //     }
    // }

    function transferMerchant(address _merchant) external override onlyFactory {
        _merchant = _merchant.toEvmAddress();
        require(_merchant != address(0),"_merchant can not be address 0");
        address old = merchant;
        merchant = _merchant;
        
        emit MerchantTransfered(old,_merchant);
    }

    function pause() external override onlyFactory {
        _pause();
    }

    function unpause() external override onlyFactory {
        _unpause();
    }
}
// File: libs/Ownable.sol

// File: @openzeppelin/contracts/ownership/Ownable.sol
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
// File: VaultFactory.sol

contract VaultFactory is Ownable,ReentrancyGuard,IVaultFactory {
    using SafeMath for uint256;
    using EvmAddress for address;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chain,address verifyingContract)");
    bytes32 public constant CREATE_VAULT_HASH = keccak256("CreateVault(uint256 merchantCode,address merchantAddress,uint256 rand)");
    bytes32 public constant vaultFactoryNameHash = keccak256("PayVaultFactory");

    address public immutable override WETH;
    uint public immutable override periodDuration;
    address public override feeTo;

    mapping(uint256 => bool) public isUsedRand;

    mapping(address => bool) public override isSystemAuditor;
    mapping(address => bool) public override isPlatformAuditor;
    mapping(bytes32 => uint256) public auditorPeriodLimitOf;
    mapping(bytes32 => mapping(uint256 => uint256)) public periodAuthorizedOf;

    mapping(uint256 => address) public vaultOf;
    mapping(address => uint256) public vaultMerchantIDOf;

    bool public override allVaultPaused;

    address public cfo;

    uint public nonce = 1;

    event VaultCreated(address signer,uint merchantCode,address merchantAddress,address vault,uint timestamp);
    event AuditorPeriodLimitChanged(address signer, address auditor,address token,uint oldLimit,uint newLimit,uint timestamp);
    event AuditorStatusChanged(address signer,address auditor,bool status,uint timestamp);
    event SystemAuditorStatusChanged(address caller,address auditor,bool status,uint timestamp);
    event CfoChanged(address oldCfo,address newCfo);

    modifier checkAndUseRand(uint rand) {
        require(rand > 0,"rand can not be 0");
        require(!isUsedRand[rand],"rand used");
        isUsedRand[rand] = true;
        _;
    }

    constructor(
        address _weth,
        uint _periodDuration,
        address _cfo
    ){
        require(_weth != address(0),"weth can not be address 0");
        require(_periodDuration > 0,"periodDuration can not be 0");

        WETH = _weth.toEvmAddress();
        periodDuration = _periodDuration;

        cfo = _cfo.toEvmAddress();
        feeTo = _cfo.toEvmAddress();
    }

    function createVault(uint merchantCode,address merchantAddress,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        merchantAddress = merchantAddress.toEvmAddress();
        require(merchantCode > 0,"merchantCode can not be 0");
        require(merchantAddress != address(0),"merchantAddress can not be address 0");
        require(vaultOf[merchantCode] == address(0),"merchantCode existed");

        address signatory = recoverCreateSign(merchantCode,merchantAddress,rand,v,r,s);
        require(signatory == cfo,"unauthorized");

        bytes memory bytecode = type(Vault).creationCode;
        bytes32 salt = keccak256(abi.encode(merchantCode,nonce++));
        address vaultContract;
        assembly {
            vaultContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        vaultContract=vaultContract.toEvmAddress();

        vaultOf[merchantCode] = vaultContract;
        vaultMerchantIDOf[vaultContract] = merchantCode;

        IVault(vaultContract).init(merchantAddress);

        emit VaultCreated(signatory,merchantCode,merchantAddress,vaultContract,block.timestamp);
    }

    function recoverCreateSign(uint merchantCode,address merchantAddress,uint rand,uint8 v,bytes32 r,bytes32 s) public view returns(address){
        merchantAddress = merchantAddress.toEvmAddress();
        bytes32 structHash = keccak256(abi.encode(CREATE_VAULT_HASH, merchantCode, merchantAddress, rand));
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, vaultFactoryNameHash, ChainId.get(), address(this)));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0),"invalid signature");

        return signatory.toEvmAddress();
    }

    function updateAuditorAuthorized(address auditor,address token,uint amount) external override returns(bool) {
        auditor = auditor.toEvmAddress();
        token = token.toEvmAddress();

        require(vaultMerchantIDOf[msg.sender] > 0,"factory_updateAuditorAuthorized: invalid caller");
        require(isPlatformAuditor[auditor],"factory_updateAuditorAuthorized: invalid system auditor");

        bytes32 key = PayHelper.auditorTokenKey(auditor, token);
        uint periodKey = PayHelper.periodStart(block.timestamp,periodDuration);
        uint authorizedAmount = periodAuthorizedOf[key][periodKey];
        require(authorizedAmount.add(amount) <= auditorPeriodLimitOf[key],"factory_updateAuditorAuthorized: exceeds auditor period limit");
        
        periodAuthorizedOf[key][periodKey] = periodAuthorizedOf[key][periodKey].add(amount);

        return true;
    }

    function setAuditorStatus(address auditor,bool enableStatus,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();

        address signatory = PayHelper.recoverSetAuditorStatusSign(vaultFactoryNameHash, auditor, enableStatus, rand, v, r, s);
        require(signatory == cfo,"unauthorized");

        _setAuditorStatus(auditor,enableStatus,signatory);
    }

    function _setAuditorStatus(address auditor,bool enableStatus,address signer) internal {
        require(auditor != address(0),"auditor can not be address 0");
        require(!isSystemAuditor[auditor],"auditor can not be system auditor");

        isPlatformAuditor[auditor] = enableStatus;

        emit AuditorStatusChanged(signer,auditor,enableStatus,block.timestamp);
    }

    function setAuditorPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();
        tokens = EvmAddress.convertAddresses(tokens);
        
        address signatory = PayHelper.recoverSetAuditorPeriodLimitsSign(vaultFactoryNameHash, auditor, tokens, periodLimits, rand, v, r, s);
        require(signatory == cfo,"unauthorized");

        _setAuditorPeriodLimits(auditor,tokens,periodLimits,signatory);
    }

    function _setAuditorPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits,address signer) internal {
        require(auditor != address(0),"auditor can not be address 0");
        require(tokens.length > 0,"tokens can not be empty");
        require(tokens.length == periodLimits.length,"length of periodLimits must equals to length of tokens");
        require(isPlatformAuditor[auditor],"invalid auditor");

        for(uint i=0;i<tokens.length;i++){
            require(tokens[i] != address(0),"included token address 0");
            bytes32 key = PayHelper.auditorTokenKey(auditor,tokens[i]);
            uint old = auditorPeriodLimitOf[key];
            auditorPeriodLimitOf[key] = periodLimits[i];

            emit AuditorPeriodLimitChanged(signer,auditor,tokens[i],old,periodLimits[i],block.timestamp);
        }
    }

    function addAuditorAndSetPeriodLimits(address auditor,address[] memory tokens, uint[] calldata periodLimits,uint rand,uint8 v,bytes32 r,bytes32 s) external checkAndUseRand(rand) nonReentrant {
        auditor = auditor.toEvmAddress();
        tokens = EvmAddress.convertAddresses(tokens);
        
        address signatory = PayHelper.recoverAddAuditorAndSetPeriodLimitsSign(vaultFactoryNameHash, auditor, tokens, periodLimits, rand, v, r, s);
        require(signatory == cfo,"unauthorized");

        _setAuditorStatus(auditor, true, signatory);
       _setAuditorPeriodLimits(auditor,tokens,periodLimits,signatory);
    }

    function setSystemAuditorStatus(address sysAuditor,bool enableStatus) external onlyOwner {
        sysAuditor = sysAuditor.toEvmAddress();

        require(sysAuditor!=address(0),"system auditor can not be address 0");
        require(!isPlatformAuditor[sysAuditor],"auditor can not be platform auditor");

        isSystemAuditor[sysAuditor] = enableStatus;

        emit SystemAuditorStatusChanged(msg.sender,sysAuditor,enableStatus,block.timestamp);
    }

    function transferCfo(address _cfo) external {
        _cfo = _cfo.toEvmAddress();
        require(msg.sender == cfo,"caller must be cfo");
        address oldCfo = cfo;
        cfo = _cfo;

        emit CfoChanged(oldCfo, _cfo);
    }

    function setFeeTo(address _feeTo) external onlyOwner {
        _feeTo = _feeTo.toEvmAddress();
        require(_feeTo != address(0),"_feeTo can not be address 0");
        feeTo = _feeTo;
    }

    function transferMerchant(address vault, address _merchant) external onlyOwner {
        vault = vault.toEvmAddress();
        _merchant = _merchant.toEvmAddress();

        require(vault != address(0),"vault can not be address 0");
        require(_merchant != address(0),"_merchant can not be address 0");
        IVault(vault).transferMerchant(_merchant);
    }

    function pauseVault(address vault) external onlyOwner {
        vault = vault.toEvmAddress();

        require(vault != address(0),"vault can not be address 0");
        IVault(vault).pause();
    }

    function unpauseVault(address vault) external onlyOwner {
        vault = vault.toEvmAddress();

        require(vault != address(0),"vault can not be address 0");
        IVault(vault).unpause();
    }

    function pauseAllVault() external onlyOwner {
        allVaultPaused = true;
    }

    function unpauseAllVault() external onlyOwner {
        allVaultPaused = false;
    }
}