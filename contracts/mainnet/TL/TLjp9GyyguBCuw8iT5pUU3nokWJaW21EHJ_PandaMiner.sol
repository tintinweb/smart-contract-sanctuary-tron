//SourceUnit: Miner copy.sol

/*
            ██████   █████  ███    ██ ██████   █████  
            ██   ██ ██   ██ ████   ██ ██   ██ ██   ██ 
            ██████  ███████ ██ ██  ██ ██   ██ ███████ 
            ██      ██   ██ ██  ██ ██ ██   ██ ██   ██ 
            ██      ██   ██ ██   ████ ██████  ██   ██ 
                                                    
                                                    
             ███    ███ ██ ███    ██ ███████ ██████    
             ████  ████ ██ ████   ██ ██      ██   ██   
             ██ ████ ██ ██ ██ ██  ██ █████   ██████    
             ██  ██  ██ ██ ██  ██ ██ ██      ██   ██   
             ██      ██ ██ ██   ████ ███████ ██   ██   
                                                

        Website        :   https://pandaminertrx.com/

        Telegram       :   https://t.me/PandaMinerEntry

        Twitter        :   https://twitter.com/PandaMinerTRX
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

library ReferalCode {
    function _generate(uint256 _nonce) internal view returns (string memory) {
        uint rand = uint(
            keccak256(abi.encodePacked(msg.sender, block.timestamp, _nonce))
        );
        string memory hash = _toAlphabetString(rand);
        return _substring(hash, 0, 5);
    }

    function _toAlphabetString(
        uint value
    ) internal pure returns (string memory) {
        bytes
            memory alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory result = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            result[i] = alphabet[value % 62];
            value /= 62;
        }
        return string(result);
    }

    function _substring(
        string memory str,
        uint startIndex,
        uint endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = 0; i < endIndex - startIndex; i++) {
            result[i] = strBytes[i + startIndex];
        }
        return string(result);
    }
}

contract PandaMiner is Ownable, ReentrancyGuard {
    uint256 public dailyAPY;
    uint256 public accTokenPerShare;
    uint256 public endTimestamp;
    uint256 public startTimestamp;
    uint256 public lastRewardTimestamp;
    uint256 public rewardPerSecond;
    bool public vaultOpen;
    address public devAddress;

    mapping(address => UserInfo) public userInfo;
    mapping(string => address) public referer;
    mapping(address => string) public referalCode;

    uint256 public totalReferrer;
    uint256 public PRECISION_FACTOR;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    event Deposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event Compound(address indexed user, uint256 amount);
    event NewRewardPerSecond(uint256 rewardPerSecond);

    constructor(
        uint256 _rewardPerSecond,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        address _devWallet,
        uint256 _dailyAPY
    ) {
        require(
            _startTimestamp < _endTimestamp,
            "New startTimestamp must be lower than new endTimestamp"
        );

        devAddress = _devWallet;

        rewardPerSecond = _rewardPerSecond;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        dailyAPY = _dailyAPY;

        uint256 decimalsRewardToken = 18;

        PRECISION_FACTOR = uint256(10 ** (uint256(30) - decimalsRewardToken));

        lastRewardTimestamp = startTimestamp;
    }

    function setVaultOpen(bool _vaultOpen) external onlyOwner {
        vaultOpen = _vaultOpen;
    }

    function deposit(string memory referral) external payable nonReentrant {
        require(vaultOpen, "Vault is closed");
        require(msg.value > 0, "Deposit: Amount must be greater than 0");

        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        user.amount = user.amount + msg.value;
        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        if (bytes(referral).length > 0) {
            if (
                referer[referral] != msg.sender &&
                referer[referral] != address(0x0)
            ) {
                uint256 devFee = (msg.value * 10) / 100;
                uint256 refFee = (msg.value * 2) / 100;

                (bool sent, ) = payable(devAddress).call{value: devFee}("");
                (sent, ) = payable(referer[referral]).call{value: refFee}("");
                require(sent, "Failed to send dev/ref fees");
            } else {
                uint256 devFee = (msg.value * 12) / 100;
                (bool sent, ) = payable(devAddress).call{value: devFee}("");
                require(sent, "Failed to send dev fees");
            }
        } else {
            uint256 devFee = (msg.value * 12) / 100;
            (bool sent, ) = payable(devAddress).call{value: devFee}("");
            require(sent, "Failed to send dev fees");
        }

        emit Deposit(msg.sender, msg.value);
    }

    function claim() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        uint256 pending = _pendingRewards(msg.sender);

        if (pending > 0) {
            uint256 contractBalance = address(this).balance;
            if (contractBalance > pending) {
                (bool sent, ) = payable(msg.sender).call{value: pending}("");
                require(sent, "Failed to claim");
            } else {
                (bool sent, ) = payable(msg.sender).call{
                    value: address(this).balance
                }("");
                require(sent, "Failed to claim");
            }
        }

        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        emit Claim(msg.sender, pending);
    }

    function compoundRewards() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        uint256 pending = _pendingRewards(msg.sender);

        require(pending > 0, "Nothing to compound");

        user.amount += pending;
        user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

        emit Compound(msg.sender, pending);
    }

    function updateRewardPerSecond(
        uint256 _rewardPerSecond
    ) external onlyOwner {
        require(block.timestamp < startTimestamp, "Pool has started");
        uint256 decimalsRewardToken = 18;
        require(
            (PRECISION_FACTOR * _rewardPerSecond) /
                (10 ** decimalsRewardToken) >=
                100_000_000,
            "rewardPerSecond must be larger"
        );
        rewardPerSecond = _rewardPerSecond;
        emit NewRewardPerSecond(_rewardPerSecond);
    }

    function getPendingRewards(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = address(this).balance;
        if (block.timestamp > lastRewardTimestamp && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(
                lastRewardTimestamp,
                block.timestamp
            );
            uint256 bambooReward = multiplier * rewardPerSecond;
            uint256 adjustedTokenPerShare = accTokenPerShare +
                (bambooReward * PRECISION_FACTOR) /
                stakedTokenSupply;
            return
                (user.amount * adjustedTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        } else {
            return
                (user.amount * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        }
    }

    function _updatePool() internal {
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }

        uint256 stakedTokenSupply = address(this).balance;

        if (stakedTokenSupply == 0) {
            lastRewardTimestamp = block.timestamp;
            return;
        }

        rewardPerSecond = ((stakedTokenSupply * dailyAPY) / 100) / 1 days;

        uint256 multiplier = _getMultiplier(
            lastRewardTimestamp,
            block.timestamp
        );
        uint256 bambooReward = multiplier * rewardPerSecond;
        accTokenPerShare =
            accTokenPerShare +
            (bambooReward * PRECISION_FACTOR) /
            stakedTokenSupply;
        lastRewardTimestamp = block.timestamp;
    }

    function _getMultiplier(
        uint256 _from,
        uint256 _to
    ) internal view returns (uint256) {
        if (_to <= endTimestamp) {
            return _to - _from;
        } else if (_from >= endTimestamp) {
            return 0;
        } else {
            return endTimestamp - _from;
        }
    }

    // only owner can call this function after the pool end time (1711846800)
    // if no more interactions with the contract (no claim/compound)
    function emergencyFunding() public payable {
        require(msg.sender == devAddress, "Only owner");
        require(block.timestamp > 1711846800, "Can't call this function yet");
        (bool sent, ) = payable(devAddress).call{value: address(this).balance}("");
        require(sent, "Failed to send");
    }

    function _pendingRewards(address _user) private view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = address(this).balance;
        if (block.timestamp > lastRewardTimestamp && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(
                lastRewardTimestamp,
                block.timestamp
            );
            uint256 bambooReward = multiplier * rewardPerSecond;
            uint256 adjustedTokenPerShare = accTokenPerShare +
                (bambooReward * PRECISION_FACTOR) /
                stakedTokenSupply;
            return
                (user.amount * adjustedTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        } else {
            return
                (user.amount * accTokenPerShare) /
                PRECISION_FACTOR -
                user.rewardDebt;
        }
    }

    function createReferralCode() public {
        string memory code = ReferalCode._generate(totalReferrer);

        referer[code] = msg.sender;
        referalCode[msg.sender] = code;

        totalReferrer++;
    }
}