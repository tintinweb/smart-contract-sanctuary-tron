//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity 0.8.0;

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

//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity 0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

//SourceUnit: IMultiSignWalletFactory.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IMultiSignWalletFactory {
    function getWalletImpl() external view returns(address) ;
}

//SourceUnit: MultiSignWallet.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./SafeMath256.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./SignMessage.sol";

contract WalletOwner {
    uint16  constant MIN_REQUIRED = 1;
    uint256 required;
    mapping(address => uint256) activeOwners;
    address[] owners;
    mapping(address => uint256) exceptionTokens;

    event OwnerRemoval(address indexed owner);
    event OwnerAddition(address indexed owner);
    event SignRequirementChanged(uint256 required);

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getOwnerRequiredParam() public view returns (uint256) {
        return required;
    }

    function isOwner(address addr) public view returns (bool) {
        return activeOwners[addr] > 0;
    }
}

contract WalletSecurity {
    uint256 constant MIN_INACTIVE_INTERVAL = 3 days; // 3days;
    uint256 constant securityInterval = 3 days;
    bool initialized;
    bool securitySwitch = false;
    uint256 deactivatedInterval = 0;
    uint256 lastActivatedTime = 0;

    mapping(bytes32 => uint256) transactions;
    event SecuritySwitchChange(bool swithOn, uint256 interval);

    modifier onlyNotInitialized() {
        require(!initialized, "the wallet already initialized");
        _;
        initialized = true;
    }

    modifier onlyInitialized() {
        require(initialized, "the wallet not init yet");
        _;
    }

    function isSecuritySwitchOn() public view returns (bool) {
        return securitySwitch;
    }

    function getDeactivatedInterval() public view returns (uint256) {
        return deactivatedInterval;
    }

    function getLastActivatedTime() public view returns (uint256) {
        return lastActivatedTime;
    }

}

contract MultiSignWallet is WalletOwner, WalletSecurity {
    using SafeMath256 for uint256;

    event Deposit(address indexed from, uint256 value);
    event Transfer(address indexed token, address indexed to, uint256 value);
    event ExecuteWithData(address indexed token, uint256 value);
    event ExceptionTokenRemove(address indexed token);
    event ExceptionTokenAdd(address indexed token);

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "the wallet operation is expired");
        _;
    }

    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function initialize(address[] memory _owners, uint256 _required, bool _switchOn, uint256 _deactivatedInterval, address[] memory _exceptionTokens) external onlyNotInitialized returns(bool) {
        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        if (_switchOn) {
            require(_deactivatedInterval >= MIN_INACTIVE_INTERVAL, "inactive interval must more than 3days");
            securitySwitch = _switchOn;
            deactivatedInterval = _deactivatedInterval;
            emit SecuritySwitchChange(securitySwitch, deactivatedInterval);
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the address can't be 0x");
            }

            if (activeOwners[_owners[i]] > 0 ) {
                revert("the owners must be distinct");
            }

            activeOwners[_owners[i]] = block.timestamp;
            emit OwnerAddition(_owners[i]);
        }

        require(_owners.length >= _required, "wallet owners must more than the required.");
        required = _required;
        emit SignRequirementChanged(required);
        owners = _owners;
        _updateActivatedTime();

        if (_exceptionTokens.length > 0) {
            return _addExceptionToken(_exceptionTokens);
        }

        return true;
    }

    function addOwner(address[] memory _newOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(_validOwnerAddParams(_newOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerModifyMessage(address(this), getChainID(), _newOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        address[] memory _oldOwners;
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function removeOwner(address[] memory _oldOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(_validOwnerRemoveParams(_oldOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerModifyMessage(address(this), getChainID(), _oldOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.timestamp;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        address[] memory _newOwners;
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function replaceOwner(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(_validOwnerReplaceParams(_oldOwners, _newOwners, _required), "invalid params");
        bytes32 message = SignMessage.ownerReplaceMessage(address(this), getChainID(), _oldOwners, _newOwners, _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        return _updateOwners(_oldOwners, _newOwners, _required);
    }

    function changeOwnerRequirement(uint256 _required, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        require(owners.length >= _required, "the owners must more than the required");
        bytes32 message = SignMessage.ownerRequiredMessage(address(this), getChainID(), _required, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        required = _required;
        emit SignRequirementChanged(required);

        return true;
    }

    function changeSecurityParams(bool _switchOn, uint256 _deactivatedInterval, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        bytes32 message = SignMessage.securitySwitchMessage(address(this), getChainID(), _switchOn, _deactivatedInterval, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        if (_switchOn) {
            securitySwitch = true;
            require(_deactivatedInterval >= MIN_INACTIVE_INTERVAL, "inactive interval must more than 3days");
            deactivatedInterval = _deactivatedInterval;
        } else {
            securitySwitch = false;
            deactivatedInterval = 0;
        }

        emit SecuritySwitchChange(_switchOn, deactivatedInterval);

        return true;
    }

    function transfer(address tokenAddress, address payable to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        if(tokenAddress == address(0x0)) {
            return _transferNativeToken(to, value, salt, vs, rs, ss);
        }
        return _transferContractToken(tokenAddress, to, value, salt, vs, rs, ss);
    }

    function execute(address contractAddress, uint256 value, bytes memory data, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(contractAddress != address(this), "not allow transfer to yourself");
        bytes32 message = SignMessage.executeWithDataMessage(address(this), getChainID(), contractAddress, value, salt, data);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        (bool success,) = contractAddress.call{value: value}(data);
        require(success, "contract execution Failed");
        emit ExecuteWithData(contractAddress, value);
        return true;
    }

    function batchTransfer(address tokenAddress, address[] memory recipients, uint256[] memory amounts, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(recipients.length > 0 && recipients.length == amounts.length, "parameters invalid");
        bytes32 message = SignMessage.batchTransferMessage(address(this), getChainID(), tokenAddress, recipients, amounts, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        for(uint256 i = 0; i < recipients.length; i++) {
            _transfer(tokenAddress, recipients[i], amounts[i]);
            emit Transfer(tokenAddress, recipients[i], amounts[i]);
        }
        return true;
    }

    function addExceptionToken(address[] memory tokens, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(tokens.length > 0, "input tokens empty");
        bytes32 message = SignMessage.modifyExceptionTokenMessage(address(this), getChainID(), tokens, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        return _addExceptionToken(tokens);
    }

    function removeExceptionToken(address[] memory tokens, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss, uint256 deadline) public onlyInitialized ensure(deadline) returns (bool) {
        require(tokens.length > 0, "input tokens empty");
        bytes32 message = SignMessage.modifyExceptionTokenMessage(address(this), getChainID(), tokens, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");

        return _removeExceptionToken(tokens);
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function getRequired() public view returns (uint256) {
        if(!securitySwitch) {
            return required;
        }

        uint256 _deactivate = block.timestamp;
        if (_deactivate <= lastActivatedTime + deactivatedInterval) {
            return required;
        }

        _deactivate = _deactivate.sub(lastActivatedTime).sub(deactivatedInterval).div(securityInterval);
        if (required > _deactivate) {
            return required.sub(_deactivate);
        }

        return MIN_REQUIRED;
    }

    function getTransactionMessage(bytes32 message) public view returns (uint256) {
        return transactions[message];
    }

    function isExceptionToken(address token) public view returns (bool) {
        return exceptionTokens[token] != 0;
    }

    function _transferContractToken(address tokenAddress, address to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) internal returns (bool) {
        require(to != address(this), "not allow transfer to yourself");
        require(value > 0, "transfer value must more than 0");
        bytes32 message = SignMessage.transferMessage(address(this), getChainID(), tokenAddress, to, value, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        _safeTransfer(tokenAddress, to, value);
        emit Transfer(tokenAddress, to, value);
        return true;
    }

    function _transferNativeToken(address payable to, uint256 value, bytes32 salt, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) internal returns (bool) {
        require(to != address(this), "not allow transfer to yourself");
        require(value > 0, "transfer value must more than 0");
        require(address(this).balance >= value, "balance not enough");
        bytes32 message = SignMessage.transferMessage(address(this), getChainID(), address(0x0), to, value, salt);
        require(getTransactionMessage(message) == 0, "transaction may has been excuted");
        transactions[message] = block.number;
        require(_validSignature(message, vs, rs, ss), "invalid signatures");
        _safeTransferNative(to, value);
        emit Transfer(address(0x0), to, value);
        return true;
    }

    function _transfer(address tokenAddress, address recipient, uint256 value) internal {
        require(value > 0, "transfer value must more than 0");
        require(recipient != address(this), "not allow transfer to yourself");
        if (tokenAddress == address(0x0)) {
            _safeTransferNative(recipient, value);
            return;
        }
        _safeTransfer(tokenAddress, recipient, value);
    }

    function _updateActivatedTime() internal {
        lastActivatedTime = block.timestamp;
    }

    function _addExceptionToken(address[] memory tokens) internal returns(bool) {
        for(uint256 i = 0; i < tokens.length; i++) {
            if(!isExceptionToken(tokens[i])) {
                require(tokens[i] != address(0x0), "the token address can't be 0x");
                exceptionTokens[tokens[i]] = block.number;
                emit ExceptionTokenAdd(tokens[i]);
            }
        }
        return true;
    }

    function _removeExceptionToken(address[] memory tokens) internal returns(bool) {
        for(uint256 i = 0; i < tokens.length; i++) {
            if(isExceptionToken(tokens[i])) {
                require(tokens[i] != address(0x0), "the token address can't be 0x");
                exceptionTokens[tokens[i]] = 0;
                emit ExceptionTokenRemove(tokens[i]);
            }
        }
        return true;
    }

    function _validOwnerAddParams(address[] memory _owners, uint256 _required) private view returns (bool) {
        require(_owners.length > 0, "the new owners list can't be emtpy");
        require(_required >= MIN_REQUIRED, "the signed owner count must than 1");
        uint256 ownerCount = _owners.length;
        ownerCount = ownerCount.add(owners.length);
        require(ownerCount >= _required, "the owner count must more than the required");
        return _distinctAddOwners(_owners);
    }

    function _validOwnerRemoveParams(address[] memory _owners, uint256 _required) private view returns (bool) {
        require(_owners.length > 0 && _required >= MIN_REQUIRED, "invalid parameters");
        uint256 ownerCount = owners.length;
        ownerCount = ownerCount.sub(_owners.length);
        require(ownerCount >= _required, "the owners must more than the required");
        return _distinctRemoveOwners(_owners);
    }

    function _validOwnerReplaceParams(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required) private view returns (bool) {
        require(_oldOwners.length >0 || _newOwners.length > 0, "the two input owner list can't both be empty");
        require(_required >= MIN_REQUIRED, "the signed owner's count must than 1");
        _distinctRemoveOwners(_oldOwners);
        _distinctAddOwners(_newOwners);
        uint256 ownerCount = owners.length;
        ownerCount = ownerCount.add(_newOwners.length).sub(_oldOwners.length);
        require(ownerCount >= _required, "the owner's count must more than the required");
        return true;
    }

    function _distinctRemoveOwners(address[] memory _owners) private view returns (bool) {
        for(uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the remove address can't be 0x.");
            }

            if(activeOwners[_owners[i]] == 0) {
                revert("the remove address must be a owner.");
            }

            for(uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    revert("the remove address must be distinct");
                }
            }
        }
        return true;
    }

    function _distinctAddOwners(address[] memory _owners) private view returns (bool) {
        for(uint256 i = 0; i < _owners.length; i++) {
            if (_owners[i] == address(0x0)) {
                revert("the new address can't be 0x.");
            }

            if (activeOwners[_owners[i]] != 0) {
                revert("the new address is already a owner");
            }

            for(uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    revert("the new address must be distinct");
                }
            }
        }
        return true;
    }

    function _validSignature(bytes32 recoverMsg, uint8[] memory vs, bytes32[] memory rs, bytes32[] memory ss) private returns (bool) {
        require(vs.length == rs.length);
        require(rs.length == ss.length);
        require(vs.length <= owners.length);
        require(vs.length >= getRequired());

        address[] memory signedAddresses = new address[](vs.length);
        for (uint256 i = 0; i < vs.length; i++) {
            signedAddresses[i] = ecrecover(recoverMsg, vs[i]+27, rs[i], ss[i]);
        }

        require(_distinctSignedOwners(signedAddresses), "signed owner must be distinct");
        _updateActiveOwners(signedAddresses);
        _updateActivatedTime();
        return true;
    }

    function _updateOwners(address[] memory _oldOwners, address[] memory _newOwners, uint256 _required) private returns (bool) {
        for(uint256 i = 0; i < _oldOwners.length; i++) {
            for (uint256 j = 0; j < owners.length; j++) {
                if (owners[j] == _oldOwners[i]) {
                    activeOwners[owners[j]] = 0;
                    owners[j] = owners[owners.length - 1];
                    owners.pop();
                    emit OwnerRemoval(_oldOwners[i]);
                    break;
                }
            }
        }

        for(uint256 i = 0; i < _newOwners.length; i++) {
            owners.push(_newOwners[i]);
            activeOwners[_newOwners[i]] = block.timestamp;
            emit OwnerAddition(_newOwners[i]);
        }

        require(owners.length >= _required, "the owners must more than the required");
        required = _required;
        emit SignRequirementChanged(required);

        return true;
    }

    function _updateActiveOwners(address[] memory _owners) private returns (bool){
        for (uint256 i = 0; i < _owners.length; i++) {
            activeOwners[_owners[i]] = block.timestamp;
        }
        return true;
    }

    function _distinctSignedOwners(address[] memory _owners) private view returns (bool) {
        if (_owners.length > owners.length) {
            return false;
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            if(activeOwners[_owners[i]] == 0) {
                return false;
            }

            for (uint256 j = 0; j < i; j++) {
                if(_owners[j] == _owners[i]) {
                    return false;
                }
            }
        }
        return true;
    }

    function _safeTransfer(address token, address recipient, uint256 value) internal {
        if(isExceptionToken(token)) {
            (bool success, ) = token.call(abi.encodeWithSelector(IERC20(token).transfer.selector, recipient, value));
            require(success, "ERC20 transfer failed");
            return;
        }
        SafeERC20.safeTransfer(IERC20(token), recipient, value);
    }

    function _safeTransferNative(address recipient, uint256 value) internal {
        (bool success,) = recipient.call{value:value}(new bytes(0));
        require(success, "transfer native failed");
    }
}

//SourceUnit: MultiSignWalletFactory.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./MultiSignWalletProxy.sol";
import "./IMultiSignWalletFactory.sol";


contract MultiSignWalletFactory is IMultiSignWalletFactory {
    address payable immutable private walletImpl;
    event NewWallet(address indexed wallet);
    bytes4 internal constant _INITIALIZE = bytes4(keccak256(bytes("initialize(address[],uint256,bool,uint256,address[])")));
    constructor(address payable _walletImpl) {
        walletImpl = _walletImpl;
    }

    function create(address[] calldata _owners, uint _required, bytes32 salt, bool _securitySwitch, uint _inactiveInterval, address[] calldata _execptionTokens) public returns (address) {
        MultiSignWalletProxy wallet = new MultiSignWalletProxy{salt: salt}();
        (bool success, bytes memory data) = address(wallet).call(abi.encodeWithSelector(_INITIALIZE, _owners, _required, _securitySwitch, _inactiveInterval, _execptionTokens));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "create wallet failed");
        emit NewWallet(address(wallet));
        return address(wallet);
    }

    function getWalletImpl() external override view returns(address) {
        return walletImpl;
    }
}


//SourceUnit: MultiSignWalletProxy.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./MultiSignWallet.sol";
import "./IMultiSignWalletFactory.sol";

contract MultiSignWalletProxy {
    address immutable private walletFactory;

    constructor() {
        walletFactory = msg.sender;
    }

    receive() external payable {}

    fallback() external {
        address impl = IMultiSignWalletFactory(walletFactory).getWalletImpl();
        assembly {
            let ptr := mload(0x40)
            let size := calldatasize()
            calldatacopy(ptr, 0, size)
            let result := delegatecall(gas(), impl, ptr, size, 0, 0)
            size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
}

//SourceUnit: SafeERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

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

//SourceUnit: SafeMath256.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

library SafeMath256 {
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


//SourceUnit: SignMessage.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library SignMessage {
    function transferMessage(address wallet, uint256 chainID, address tokenAddress, address to, uint256 value, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, tokenAddress, to, value, salt));
        return messageToSign(message);
    }

    function executeWithDataMessage(address wallet, uint256 chainID, address contractAddress, uint256 value, bytes32 salt, bytes memory data) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, contractAddress, value, salt, data));
        return messageToSign(message);
    }

    function batchTransferMessage(address wallet, uint256 chainID, address tokenAddress, address[] memory recipients, uint256[] memory amounts, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, tokenAddress, recipients, amounts, salt));
        return messageToSign(message);
    }

    function ownerReplaceMessage(address wallet, uint256 chainID, address[] memory _oldOwners, address[] memory _newOwners, uint256 _required, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _oldOwners, _newOwners, _required, salt));
        return messageToSign(message);
    }

    function ownerModifyMessage(address wallet, uint256 chainID, address[] memory _owners, uint256 _required, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _owners, _required, salt));
        return messageToSign(message);
    }

    function ownerRequiredMessage(address wallet, uint256 chainID, uint256 _required, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _required, salt));
        return messageToSign(message);
    }

    function securitySwitchMessage(address wallet, uint256 chainID, bool swithOn, uint256 _deactivatedInterval, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, swithOn, _deactivatedInterval, salt));
        return messageToSign(message);
    }

    function modifyExceptionTokenMessage(address wallet, uint256 chainID, address[] memory _tokens, bytes32 salt) internal pure returns (bytes32) {
        bytes32 message = keccak256(abi.encodePacked(wallet, chainID, _tokens, salt));
        return messageToSign(message);
    }

    function messageToSign(bytes32 message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19TRON Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }
}