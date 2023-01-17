//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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


//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}


//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

//SourceUnit: IExchange.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

interface IExchange {

    struct User{
        uint256 userId;
        address userAddress;
        uint256 inviterId;
        uint256 userLayer;
        uint256[] inviteeId;
        uint256 createTime;
        uint256 amountAtoN;
    }

    function getUserId(address) external view returns(uint256);
    function getUserAddress(uint256) external view returns(address);
    function getUserData(uint256) external view returns(User memory);
    function includedUser(address) external view returns(bool);

    

    function getAmountUserAtoN(address _userAddress) external view returns(uint256);

    
    function tNRegisterUser(address _userAddress,address _inviter) external;

    function getUserInvitee(address _userAddr)external view returns (uint[] memory _inviteeId);
    function getUserLayer(address _userAddr)external view returns (uint _userLayer);
    function getUserInviterId(address _userAddr)external view returns (uint _inviterId);
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


//SourceUnit: ReentrancyGuard.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
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


//SourceUnit: SET.sol

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////xxxxxxxxxxx///////////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
/////////////xxxxxxxxxxxxxxx/////////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
////////////xxxxxxxxxxxxxxxxxx///////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
///////////xxxxx////////////xxx//////xxx/////////////////////xx/////////////////xxxx//////////////////
//////////xxxxx//////////////xx//////xxx/////////////////////x//////////////////xxxx//////////////////
//////////xxxx////////////////x//////xxx////////////////////////////////////////xxxx//////////////////
//////////xxxxx//////////////////////xxx////////////////////////////////////////xxxx//////////////////
///////////xxxxx/////////////////////xxx////////////////////////////////////////xxxx//////////////////
////////////xxxxx////////////////////xxx////////////////////////////////////////xxxx//////////////////
/////////////xxxxx///////////////////xxx////////////////////////////////////////xxxx//////////////////
///////////////xxxxx/////////////////xxx////////////////////////////////////////xxxx//////////////////
//////////////////xxxx///////////////xxx//////////////////xx////////////////////xxxx//////////////////
////////////////////xxx//////////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
/////////////////////xxxx////////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
///////////////////////xxx///////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
////////////////////////xxxx/////////xxx///////////////////x////////////////////xxxx//////////////////
/////////////////////////xxxx////////xxx///////////////////x////////////////////xxxx//////////////////
//////////////////////////xxxx///////xxx////////////////////////////////////////xxxx//////////////////
///////////////////////////xxxx//////xxx////////////////////////////////////////xxxx//////////////////
/////x//////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
/////xx/////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
//////xx////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
//////xxxx//////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
///////xxxx////////////////xxxxx/////xxx////////////////////////////////////////xxxx//////////////////
////////xxxxx////////////xxxxxx//////xxx//////////////////////x/////////////////xxxx//////////////////
/////////xxxxxxxxxxxxxxxxxxxxx///////xxx/////////////////////xx/////////////////xxxx//////////////////
///////////xxxxxxxxxxxxxxxxx/////////xxxxxxxxxxxxxxxxxxxxxxxxxx/////////////////xxxx//////////////////
////////////xxxxxxxxxxxxxx///////////xxxxxxxxxxxxxxxxxxxxxxxxxx/////////////////xxxx//////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////Powered by BoBo_Lab///////////////////////////////////////////
/////////////////////////////////////////// TG:BoBo_Lab///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./TokenN.sol";

contract SET is TokenN {
    
    constructor(
        address _fundAddr,
        address _tokenAddrA,
        address _tokenAddrB,
        address _tokenAddrU,
        address _manager20,
        address _manager125
        
        ) TokenN(
        "SET", 
        "SET",
        _fundAddr,
        _tokenAddrA,
        _tokenAddrB,
        _tokenAddrU
        ) {
            _mint(_manager20,2857140000000000000000000);
            _mint(_manager125,178571250000000000000000);
        }
}


//SourceUnit: Strings.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


//SourceUnit: TokenN.sol

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////xxxxxxxxxxx///////////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
/////////////xxxxxxxxxxxxxxx/////////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
////////////xxxxxxxxxxxxxxxxxx///////xxxxxxxxxxxxxxxxxxxxxxxxxx//////xxxxxxxxxxxxxxxxxxxxxxxxxxxx/////
///////////xxxxx////////////xxx//////xxx/////////////////////xx/////////////////xxxx//////////////////
//////////xxxxx//////////////xx//////xxx/////////////////////x//////////////////xxxx//////////////////
//////////xxxx////////////////x//////xxx////////////////////////////////////////xxxx//////////////////
//////////xxxxx//////////////////////xxx////////////////////////////////////////xxxx//////////////////
///////////xxxxx/////////////////////xxx////////////////////////////////////////xxxx//////////////////
////////////xxxxx////////////////////xxx////////////////////////////////////////xxxx//////////////////
/////////////xxxxx///////////////////xxx////////////////////////////////////////xxxx//////////////////
///////////////xxxxx/////////////////xxx////////////////////////////////////////xxxx//////////////////
//////////////////xxxx///////////////xxx//////////////////xx////////////////////xxxx//////////////////
////////////////////xxx//////////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
/////////////////////xxxx////////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
///////////////////////xxx///////////xxxxxxxxxxxxxxxxxxxxxxx////////////////////xxxx//////////////////
////////////////////////xxxx/////////xxx///////////////////x////////////////////xxxx//////////////////
/////////////////////////xxxx////////xxx///////////////////x////////////////////xxxx//////////////////
//////////////////////////xxxx///////xxx////////////////////////////////////////xxxx//////////////////
///////////////////////////xxxx//////xxx////////////////////////////////////////xxxx//////////////////
/////x//////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
/////xx/////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
//////xx////////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
//////xxxx//////////////////xxxx/////xxx////////////////////////////////////////xxxx//////////////////
///////xxxx////////////////xxxxx/////xxx////////////////////////////////////////xxxx//////////////////
////////xxxxx////////////xxxxxx//////xxx//////////////////////x/////////////////xxxx//////////////////
/////////xxxxxxxxxxxxxxxxxxxxx///////xxx/////////////////////xx/////////////////xxxx//////////////////
///////////xxxxxxxxxxxxxxxxx/////////xxxxxxxxxxxxxxxxxxxxxxxxxx/////////////////xxxx//////////////////
////////////xxxxxxxxxxxxxx///////////xxxxxxxxxxxxxxxxxxxxxxxxxx/////////////////xxxx//////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////Powered by BoBo_Lab///////////////////////////////////////////
/////////////////////////////////////////// TG:BoBo_Lab///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.6;

import "./IERC20.sol";
import "./Context.sol";
import "./Strings.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IExchange.sol";
import "./ReentrancyGuard.sol";

abstract contract TokenN is Context, IERC20, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 private constant MAX = type(uint256).max;

    address public fundAddr;

    IExchange _Exchange;
    address _StakeN;
    address public tokenAddrA;
    address public tokenAddrB;
    address public tokenAddrU;
    uint8 public txRate;
    uint8 public burnRate;
    uint8 public botRate;
    uint8 public botBlock;
    uint256 public unburn;
    uint16 public releasedAmount;
    uint16 public releaseStep;
    uint256 public lastReleasedTime;
    bool public startRelease;

    mapping(address => bool) whiteList;
    mapping(address => bool) blackList;

    uint256 public startTradeBlock;

    uint256 public poolBalance;

    constructor(
        string memory name_,
        string memory symbol_,
        address _fundAddr,
        address _tokenAddrA,
        address _tokenAddrB,
        address _tokenAddrU
    ) {
        _name = name_;
        _symbol = symbol_;

        fundAddr = _fundAddr;

        tokenAddrA = _tokenAddrA;
        tokenAddrB = _tokenAddrB;
        tokenAddrU = _tokenAddrU;

        whiteList[address(this)] = true;
        whiteList[address(msg.sender)] = true;

        releaseStep = 5;
        startRelease = false;

        startTradeBlock = MAX;

        txRate = 6;
        burnRate = 83;

        unburn = 14142843000000000000000000;

        botBlock = 2;
        botRate = 6;

        poolBalance = 9821418750000000000000000;
    }

    function setStakeAddr(address _stakeAddr) public onlyOwner {
        _StakeN = _stakeAddr;
        whiteList[_stakeAddr] = true;
    }

    function setExchange(address _exchangeAddr) public onlyOwner {
        IExchange Exchange = IExchange(_exchangeAddr);
        _Exchange = Exchange;
        whiteList[_exchangeAddr] = true;
    }

    function getIndexAndDelOfAddr(address[] storage _array, address _addr)
        internal
        returns (bool)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == _addr) {
                _array[i] = _array[_array.length - 1];
                _array.pop();
                return true;
            }
        }
        return false;
    }

    function isIncludedOfAddr(address[] memory _array, address _addr)
        internal
        pure
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == _addr) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blackList[from], "from is on the blacklist");

        if (startRelease) {
            if (releasedAmount < 1000 && block.timestamp >= lastReleasedTime) {
                dailyRelease();
            }
        }

        uint256 unfreezeBalance = _checkReleasedAmount(from);
        require(unfreezeBalance >= amount);

        uint256 fromBalance = _balances[from];
        uint256 toBalance = _balances[to];
        uint256 fundBalance = _balances[fundAddr];

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        if (whiteList[from] || whiteList[to]) {
            _balances[to] += amount;

            emit Transfer(from, to, amount);
        } else {
            require(block.number >= startTradeBlock, "Trade not open yet");

            uint8 _txRate = txRate;

            if (block.number - startTradeBlock <= botBlock) {
                _txRate = botRate;
            }

            uint256 _fee = (amount / 100) * _txRate;
            if (unburn > 0) {
                uint256 _burnAmount = (amount / 100) * burnRate;
                if (_burnAmount >= unburn) {
                    _burnAmount = unburn;
                    txRate = 2;
                    burnRate = 0;
                }
                _totalSupply -= _burnAmount;
                unburn -= _burnAmount;
                _balances[to] += amount - _fee - _burnAmount;
                _balances[fundAddr] += _fee;

                emit Transfer(from, address(0), _burnAmount);
                emit Transfer(from, fundAddr, _fee);
                emit Transfer(from, to, amount - _fee - _burnAmount);
                assert(
                    _balances[from] +
                        _balances[to] +
                        _burnAmount +
                        _balances[fundAddr] ==
                        fromBalance + toBalance + fundBalance
                );
            } else {
                _balances[fundAddr] += _fee;
                _balances[to] += amount - _fee;

                emit Transfer(from, fundAddr, _fee);
                emit Transfer(from, to, amount - _fee);
                assert(
                    _balances[from] + _balances[to] + _balances[fundAddr] ==
                        fromBalance + toBalance + fundBalance
                );
            }
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function exchangeMint(address to, uint256 amount) external {
        require(msg.sender == address(_Exchange));
        _mint(to, amount);
    }

    function stakeMint(address to, uint256 amount) external {
        require(msg.sender == address(_StakeN));
        if (amount <= poolBalance) {
            poolBalance -= amount;
            _mint(to, amount);
        } else {
            if (poolBalance > 0) {
                uint256 _amount = poolBalance;
                poolBalance = 0;
                _mint(to, _amount);
            }
        }
    }

    function stakeTransfer(
        address from,
        address to,
        uint256 amount
    ) external {
        require(msg.sender == address(_StakeN));

        if (from != address(_StakeN)) {
            _transfer(from, to, amount);
        } else {
            if (startRelease) {
                if (
                    releasedAmount < 1000 && block.timestamp >= lastReleasedTime
                ) {
                    dailyRelease();
                }
            }
            uint256 fromBalance = _balances[from];
            require(
                fromBalance >= amount,
                "ERC20: transfer amount exceeds balance"
            );
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[to] += amount;

            emit Transfer(from, to, amount);
        }
    }

    function _checkReleasedAmount(address _userAddr)
        public
        view
        returns (uint256)
    {
        uint256 amountAToN = _Exchange.getAmountUserAtoN(_userAddr);
        uint256 frozenAmount = (amountAToN / 1000) * (1000 - releasedAmount);
        return balanceOf(_userAddr) - frozenAmount;
    }

    function setReleaseStep(uint16 _step) public onlyOwner {
        require(_step <= 1000, "0<= _step <=1000");
        releaseStep = _step;
    }

    function dailyRelease() private nonReentrant {
        require(block.timestamp >= lastReleasedTime, "Less than 24 hours");
        lastReleasedTime = block.timestamp + 86400;
        releasedAmount + releaseStep <= 1000
            ? releasedAmount += releaseStep
            : releasedAmount = 1000;
    }

    function setStartRelease(bool _state) public onlyOwner {
        startRelease = _state;
    }

    function setWhiteList(address _user, bool _state) public onlyOwner {
        whiteList[_user] = _state;
    }

    function setBlackList(address _user, bool _state) public onlyOwner {
        blackList[_user] = _state;
    }

    function setFundAddress(address _addr) public onlyOwner {
        whiteList[fundAddr] = false;
        fundAddr = _addr;
        whiteList[_addr] = true;
    }

    function setTxRate(uint8 _rate) public onlyOwner {
        require(_rate <= 100, "_rate should <=100");
        txRate = _rate;
        if (botRate < _rate) {
            botRate = _rate;
        }
    }

    function setBurnRate(uint8 _rate) public onlyOwner {
        require(_rate <= 100, "_rate should <=100");
        burnRate = _rate;
    }

    function setStartTX(bool _state) public onlyOwner {
        _state ? startTradeBlock = block.number : startTradeBlock = MAX;
    }
}