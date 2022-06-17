//SourceUnit: BaseMultiSigWallet.sol

pragma solidity 0.8.6;

import "./EnumerableSet.sol";


/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <stefan.george@consensys.net>
abstract contract BaseMultiSigWallet {
    using EnumerableSet for EnumerableSet.AddressSet;

    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 50;

    /*
     *  Storage
     */
    mapping (uint => Transaction) public transactions;
    mapping (uint => EnumerableSet.AddressSet) internal confirmations;
    EnumerableSet.AddressSet internal owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        bytes data;
        bool executed;
    }

    struct TransactionDetail {
        string method;
        address owner;
        address newOwner;
        address receiver;
        uint transactionId;
        uint amount;
        uint confirmationRequired;

        bool executed;
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(msg.sender == address(this), "sender is not wallet");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!owners.contains(owner), "owner already exists");
        _;
    }

    modifier ownerExists(address owner) {
        require(owners.contains(owner), "owner does not exist");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactionId < transactionCount, "transaction does not exist");
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId].contains(owner), "transaction is not confirmed");
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId].contains(owner), "transaction is already confirmed");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "transaction is already executed");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0), "address is null");
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
            && _required <= ownerCount
            && _required != 0
            && ownerCount != 0, "owner count or required is not valid");
        _;
    }

    constructor (address[] memory _owners, uint _required) {
        for (uint i=0; i<_owners.length; i++) {
            require(!owners.contains(_owners[i]) && _owners[i] != address(0x00), "owners not valid");
            owners.add(_owners[i]);
        }
        required = _required;
    }

    // FIXME: require + message
    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param newOwner Address of new owner.
    function addOwner(address newOwner)
    public
    onlyWallet
    ownerDoesNotExist(newOwner)
    notNull(newOwner)
    validRequirement(owners.length() + 1, required)
    {
        owners.add(newOwner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    {
        owners.remove(owner);
        uint ownerSize = owners.length();
        if (required > ownerSize)
            changeRequirement(ownerSize);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        owners.remove(owner);
        owners.add(newOwner);
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length(), _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId].add(msg.sender);
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId].remove(msg.sender);
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (_external_call(address(this), 0, txn.data.length, txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    /*
     * Internal functions
     */

    function _proposeAddOwner(address owner) internal returns (uint transactionId) {
        bytes memory data = abi.encodeWithSelector(this.addOwner.selector, owner);
        return _submitTransaction(data);
    }

    function _proposeRemoveOwner(address owner) internal returns (uint transactionId) {
        bytes memory data = abi.encodeWithSelector(this.removeOwner.selector, owner);
        return _submitTransaction(data);
    }

    function _proposeReplaceOwner(address owner, address newOwner) internal returns (uint transactionId) {
        bytes memory data = abi.encodeWithSelector(this.replaceOwner.selector, owner, newOwner);
        return _submitTransaction(data);
    }

    function _proposeChangeRequirement(uint _required) internal returns (uint transactionId) {
        bytes memory data = abi.encodeWithSelector(this.changeRequirement.selector, _required);
        return _submitTransaction(data);
    }

    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
    function _addTransaction( bytes memory data)
    internal
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
        data: data,
        executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param data Transaction data payload.
    /// @return transactionId Returns transaction ID.
    function _submitTransaction(bytes memory data)
    internal
    returns (uint transactionId)
    {
        transactionId = _addTransaction(data);
        confirmTransaction(transactionId);
    }

    // TODO: review
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function _external_call(address destination, uint value, uint dataLength, bytes memory data) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
            sub(gas(), 34710),   // 34710 is the value that solidity is currently emitting
            // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
            // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
            destination,
            value,
            d,
            dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
            x,
            0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    /*
     * View functions
     */
    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
    public
    view
    transactionExists(transactionId)
    returns (bool)
    {
        if (transactions[transactionId].executed) {
            return true;
        }

        if (confirmations[transactionId].length() < required) {
            return false;
        }

        uint ownerLength = owners.length();
        uint count = 0;
        for (uint i = 0; i < ownerLength; i ++) {
            if (confirmations[transactionId].contains(owners.at(i))) {
                count ++;
                if (count >= required) {
                    return true;
                }
            }
        }
        return false;
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return count Number of confirmations.
    function getConfirmationCount(uint transactionId)
    public
    view
    transactionExists(transactionId)
    returns (uint count)
    {
        return getConfirmations(transactionId).length;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return count Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
    public
    view
    returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
            || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
    public
    view
    returns (address[] memory)
    {
        return owners.values();
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return _confirmations Returns array of owner addresses.
    function getConfirmations(uint transactionId)
    public
    view
    transactionExists(transactionId)
    returns (address[] memory _confirmations)
    {
        // if a transaction is already executed, return the origin confirmed values.
        if (transactions[transactionId].executed) {
            return confirmations[transactionId].values();
        }

        uint ownerLength = owners.length();
        address[] memory confirms = new address[](ownerLength);

        uint count = 0;
        for (uint i = 0; i < ownerLength; i ++) {
            address owner = owners.at(i);
            if (confirmations[transactionId].contains(owner)) {
                confirms[count++] = owner;
            }
        }

        _confirmations = new address[](count);
        for (uint i = 0; i < count; i ++) {
            _confirmations[i] = confirms[i];
        }
        return _confirmations;
    }

    function getTransactionDetails(uint _from, uint _to, address _caller) public view
    returns (uint[] memory _transactionIds, TransactionDetail[] memory _details,
             uint[] memory _confirmationCounts, bool[] memory _callerConfirmed) {

        require(_from < _to, "range not valid");
        require(_to <= transactionCount, "_to should be no larger than transactionCount");

        uint _length = _to - _from;
        require(_length <= 50, "length should be no larger than 50");

        _transactionIds = new uint[] (_length);
        _details = new TransactionDetail[] (_length);
        _confirmationCounts = new uint[] (_length);
        _callerConfirmed = new bool[] (_length);

        uint i;
        uint txId;
        for (txId = _from; txId < _to; txId++) {
            _transactionIds[i] = txId;
            _details[i] = getTransactionDetail(txId);
            _confirmationCounts[i] = getConfirmationCount(txId);
            _callerConfirmed[i] = confirmations[txId].contains(_caller);
            i++;
        }

        return (_transactionIds, _details, _confirmationCounts, _callerConfirmed);
    }

    function getTransactionDetail(uint transactionId)
    public virtual view
    returns (TransactionDetail memory detail);

    function decodeBaseMethod(bool executed, bytes calldata data) public pure returns (TransactionDetail memory detail) {

        bytes4 selector = bytes4(data);
        bytes memory params = data[4:];

        if (selector == this.addOwner.selector) {
            address newOwner = abi.decode(params, (address));
            detail.method = "addOwner(address newOwner)";
            detail.newOwner = newOwner;
            detail.executed = executed;
            return detail;
        }

        if (selector == this.removeOwner.selector) {
            address owner = abi.decode(params, (address));
            detail.method = "removeOwner(address owner)";
            detail.owner = owner;
            detail.executed = executed;
            return detail;
        }

        if (selector == this.replaceOwner.selector) {
            (address owner, address newOwner) = abi.decode(params, (address, address));
            detail.method = "replaceOwner(address owner, address newOwner)";
            detail.owner = owner;
            detail.newOwner = newOwner;
            detail.executed = executed;
            return detail;
        }

        if (selector == this.changeRequirement.selector) {
            uint confirmationRequired = abi.decode(params, (uint));
            detail.method = "changeRequirement(uint _required)";
            detail.confirmationRequired = confirmationRequired;
            detail.executed = executed;
            return detail;
        }

        return detail;
    }
}


//SourceUnit: EnumerableSet.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity 0.8.6;

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
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
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


//SourceUnit: MultiSigAuthorizer.sol

pragma solidity 0.8.6;

import "./EnumerableSet.sol";
import "./BaseMultiSigWallet.sol";
import "./UsddReceiver.sol";


/// @title
contract MultiSigAuthorizer is BaseMultiSigWallet, UsddReceiver {
    using EnumerableSet for EnumerableSet.AddressSet;

    event Circulate(address indexed to, uint amount);
    event Burn(uint amount);

    /*
     *  Constants
     */
    address payable constant public BLACK_HOLE = payable(address(0x00));

    uint public releasedAmount;

    /*
     * Public functions
     */
    constructor (address[] memory _owners, uint _usdd)
    BaseMultiSigWallet(_owners, 5)
    UsddReceiver(trcToken(_usdd))
    validRequirement(_owners.length, 5)
    {
        require(_owners.length == 7, "owner length must be 7");
    }

    function proposeCirculate(address payable to, uint amount) public returns (uint transactionId) {
        require(to != address(0), "can not send to zero address");
        require(getUsddBalance() >= amount, "not enough usdd");
        bytes memory data = abi.encodeWithSelector(this.circulate.selector, to, amount);
        return _submitTransaction(data);
    }

    /// @dev Allows to send usdd to issuers. Transaction has to be sent by wallet.
    /// @param to Address of issuer.
    /// @param amount Amount to send to the issuer.
    function circulate(address payable to, uint amount)
    public
    onlyWallet
    {
        require(to != address(0), "can not send to zero address");
        require(getUsddBalance() >= amount, "not enough usdd");
        to.transferToken(amount, USDD);
        releasedAmount += amount;
        emit Circulate(to, amount);
    }

    function proposeBurn() public returns (uint transactionId) {
        bytes memory data = abi.encodeWithSelector(this.burn.selector);
        return _submitTransaction(data);
    }

    function burn() public onlyWallet {
        uint _balance = getUsddBalance();
        emit Burn(_balance);

        BLACK_HOLE.transferToken(_balance, USDD);
    }

    function proposeReplaceOwner(address owner, address newOwner) public returns (uint transactionId) {
        return super._proposeReplaceOwner(owner, newOwner);
    }

    function getTransactionDetail(uint transactionId)
    public override view
    transactionExists(transactionId)
    returns (TransactionDetail memory detail) {

        Transaction memory transaction = transactions[transactionId];

        bytes4 selector = bytes4(transaction.data);

        if (selector == this.circulate.selector || selector == this.burn.selector) {
            return this.decodeCustomMethod(transaction.executed, transaction.data);
        }

        return this.decodeBaseMethod(transaction.executed, transaction.data);
    }

    function decodeCustomMethod(bool executed, bytes calldata data) public pure returns (TransactionDetail memory detail) {
        bytes4 selector = bytes4(data);
        bytes memory params = data[4:];

        if (selector == this.circulate.selector) {
            (address to, uint amount) = abi.decode(params, (address, uint));
            detail.method = "circulate(address payable to, uint amount)";
            detail.receiver = to;
            detail.amount = amount;
            detail.executed = executed;
            return detail;
        }

        if (selector == this.burn.selector) {
            detail.method = "burn()";
            detail.executed = executed;
            return detail;
        }

        return detail;
    }

}


//SourceUnit: UsddReceiver.sol

pragma solidity 0.8.6;

contract UsddReceiver {

    event Deposit(address indexed sender, uint amount);

    trcToken public USDD;

    constructor (trcToken _usdd) {
        USDD = _usdd;
    }

    receive() external payable {
        _receive();
    }

    fallback()
    external
    payable
    {
        _receive();
    }

    function getUsddBalance() public view returns (uint) {
        return address(this).tokenBalance(USDD);
    }

    function _receive() internal {
        require(msg.value == 0, "trx is not allowed");

        if (msg.tokenvalue > 0) {
            require(msg.tokenid == USDD, "only usdd is allowed");
            emit Deposit(msg.sender, msg.tokenvalue);
        }
    }

}