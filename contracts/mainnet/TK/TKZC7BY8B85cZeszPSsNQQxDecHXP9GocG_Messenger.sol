//SourceUnit: Messenger.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// File @openzeppelin/contracts/utils/Context.sol@v4.8.3

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


// File @openzeppelin/contracts/access/Ownable.sol@v4.8.3

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File contracts/interfaces/IGasOracle.sol

interface IGasOracle {
    function chainData(uint chainId) external view returns (uint128 price, uint128 gasPrice);

    function chainId() external view returns (uint);

    function crossRate(uint otherChainId) external view returns (uint);

    function getTransactionGasCostInNativeToken(uint otherChainId, uint256 gasAmount) external view returns (uint);

    function getTransactionGasCostInUSD(uint otherChainId, uint256 gasAmount) external view returns (uint);

    function price(uint chainId) external view returns (uint);

    function setChainData(uint chainId, uint128 price, uint128 gasPrice) external;

    function setGasPrice(uint chainId, uint128 gasPrice) external;

    function setPrice(uint chainId, uint128 price) external;
}


// File contracts/GasUsage.sol

/**
 * @dev Contract module which allows children to store typical gas usage of a certain transaction on another chain.
 */
abstract contract GasUsage is Ownable {
    IGasOracle internal gasOracle;
    mapping(uint chainId => uint amount) public gasUsage;

    constructor(IGasOracle gasOracle_) {
        gasOracle = gasOracle_;
    }

    /**
     * @dev Sets the amount of gas used for a transaction on a given chain.
     * @param chainId The ID of the chain.
     * @param gasAmount The amount of gas used on the chain.
     */
    function setGasUsage(uint chainId, uint gasAmount) external onlyOwner {
        gasUsage[chainId] = gasAmount;
    }

    /**
     * @dev Sets the Gas Oracle contract address.
     * @param gasOracle_ The address of the Gas Oracle contract.
     */
    function setGasOracle(IGasOracle gasOracle_) external onlyOwner {
        gasOracle = gasOracle_;
    }

    /**
     * @notice Get the gas cost of a transaction on another chain in the current chain's native token.
     * @param chainId The ID of the chain for which to get the gas cost.
     * @return The calculated gas cost of the transaction in the current chain's native token
     */
    function getTransactionCost(uint chainId) external view returns (uint) {
        unchecked {
            return gasOracle.getTransactionGasCostInNativeToken(chainId, gasUsage[chainId]);
        }
    }
}


// File contracts/interfaces/IMessenger.sol

interface IMessenger {
    function sentMessagesBlock(bytes32 message) external view returns (uint);

    function receivedMessages(bytes32 message) external view returns (uint);

    function sendMessage(bytes32 message) external payable;

    function receiveMessage(bytes32 message, uint v1v2, bytes32 r1, bytes32 s1, bytes32 r2, bytes32 s2) external;
}


// File contracts/libraries/HashUtils.sol

library HashUtils {
    function replaceChainBytes(
        bytes32 data,
        uint8 sourceChainId,
        uint8 destinationChainId
    ) internal pure returns (bytes32 result) {
        assembly {
            mstore(0x00, data)
            mstore8(0x00, sourceChainId)
            mstore8(0x01, destinationChainId)
            result := mload(0x0)
        }
    }

    function hashWithSender(bytes32 message, bytes32 sender) internal pure returns (bytes32 result) {
        assembly {
            mstore(0x00, message)
            mstore(0x20, sender)
            result := or(
                and(
                    message,
                    0xffff000000000000000000000000000000000000000000000000000000000000 // First 2 bytes
                ),
                and(
                    keccak256(0x00, 0x40),
                    0x0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // Last 30 bytes
                )
            )
        }
    }

    function hashWithSenderAddress(bytes32 message, address sender) internal pure returns (bytes32 result) {
        assembly {
            mstore(0x00, message)
            mstore(0x20, sender)
            result := or(
                and(
                    message,
                    0xffff000000000000000000000000000000000000000000000000000000000000 // First 2 bytes
                ),
                and(
                    keccak256(0x00, 0x40),
                    0x0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff // Last 30 bytes
                )
            )
        }
    }

    function hashed(bytes32 message) internal pure returns (bytes32 result) {
        assembly {
            mstore(0x00, message)
            result := keccak256(0x00, 0x20)
        }
    }
}


// File contracts/Messenger.sol

/**
 * @dev This contract implements the Allbridge messenger cross-chain communication protocol.
 */
contract Messenger is Ownable, GasUsage, IMessenger {
    using HashUtils for bytes32;
    // current chain ID
    uint public immutable chainId;
    // supported destination chain IDs
    bytes32 public otherChainIds;

    // the primary account that is responsible for validation that a message has been sent on the source chain
    address private primaryValidator;
    // the secondary accounts that are responsible for validation that a message has been sent on the source chain
    mapping(address => bool) private secondaryValidators;
    mapping(bytes32 messageHash => uint blockNumber) public override sentMessagesBlock;
    mapping(bytes32 messageHash => uint isReceived) public override receivedMessages;

    event MessageSent(bytes32 indexed message);
    event MessageReceived(bytes32 indexed message);

    /**
     * @dev Emitted when the contract receives native gas tokens (e.g. Ether on the Ethereum network).
     */
    event Received(address, uint);

    /**
     * @dev Emitted when the mapping of secondary validators is updated.
     */
    event SecondaryValidatorsSet(address[] oldValidators, address[] newValidators);

    constructor(
        uint chainId_,
        bytes32 otherChainIds_,
        IGasOracle gasOracle_,
        address primaryValidator_,
        address[] memory validators
    ) GasUsage(gasOracle_) {
        chainId = chainId_;
        otherChainIds = otherChainIds_;
        primaryValidator = primaryValidator_;

        uint length = validators.length;
        for (uint index; index < length; ) {
            secondaryValidators[validators[index]] = true;
            unchecked {
                index++;
            }
        }
    }

    /**
     * @notice Sends a message to another chain.
     * @dev Emits a {MessageSent} event, which signals to the off-chain messaging service to invoke the `receiveMessage`
     * function on the destination chain to deliver the message.
     *
     * Requirements:
     *
     * - the first byte of the message must be the current chain ID.
     * - the second byte of the message must be the destination chain ID.
     * - the same message cannot be sent second time.
     * - messaging fee must be payed. (See `getTransactionCost` of the `GasUsage` contract).
     * @param message The message to be sent to the destination chain.
     */
    function sendMessage(bytes32 message) external payable override {
        require(uint8(message[0]) == chainId, "Messenger: wrong chainId");
        require(otherChainIds[uint8(message[1])] != 0, "Messenger: wrong destination");

        bytes32 messageWithSender = message.hashWithSenderAddress(msg.sender);

        require(sentMessagesBlock[messageWithSender] == 0, "Messenger: has message");
        sentMessagesBlock[messageWithSender] = block.number;

        require(msg.value >= this.getTransactionCost(uint8(message[1])), "Messenger: not enough fee");

        emit MessageSent(messageWithSender);
    }

    /**
     * @notice Delivers a message to the destination chain.
     * @dev Emits an {MessageReceived} event indicating the message has been delivered.
     *
     * Requirements:
     *
     * - a valid signature of the primary validator.
     * - a valid signature of one of the secondary validators.
     * - the second byte of the message must be the current chain ID.
     */
    function receiveMessage(
        bytes32 message,
        uint v1v2,
        bytes32 r1,
        bytes32 s1,
        bytes32 r2,
        bytes32 s2
    ) external override {
        bytes32 hashedMessage = message.hashed();
        require(ecrecover(hashedMessage, uint8(v1v2 >> 8), r1, s1) == primaryValidator, "Messenger: invalid primary");
        require(secondaryValidators[ecrecover(hashedMessage, uint8(v1v2), r2, s2)], "Messenger: invalid secondary");

        require(uint8(message[1]) == chainId, "Messenger: wrong chainId");

        receivedMessages[message] = 1;

        emit MessageReceived(message);
    }

    /**
     * @dev Allows the admin to withdraw the messaging fee collected in native gas tokens.
     */
    function withdrawGasTokens(uint amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev Allows the admin to set the primary validator address.
     */
    function setPrimaryValidator(address value) external onlyOwner {
        primaryValidator = value;
    }

    /**
     * @dev Allows the admin to set the addresses of secondary validators.
     */
    function setSecondaryValidators(address[] memory oldValidators, address[] memory newValidators) external onlyOwner {
        uint length = oldValidators.length;
        uint index;
        for (; index < length; ) {
            secondaryValidators[oldValidators[index]] = false;
            unchecked {
                index++;
            }
        }
        length = newValidators.length;
        index = 0;
        for (; index < length; ) {
            secondaryValidators[newValidators[index]] = true;
            unchecked {
                index++;
            }
        }
        emit SecondaryValidatorsSet(oldValidators, newValidators);
    }

    /**
     * @dev Allows the admin to update a list of supported destination chain IDs
     * @param value Each byte of the `value` parameter represents whether a chain ID with such index is supported
     *              as a valid message destination.
     */
    function setOtherChainIds(bytes32 value) external onlyOwner {
        otherChainIds = value;
    }

    fallback() external payable {
        revert("Unsupported");
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}