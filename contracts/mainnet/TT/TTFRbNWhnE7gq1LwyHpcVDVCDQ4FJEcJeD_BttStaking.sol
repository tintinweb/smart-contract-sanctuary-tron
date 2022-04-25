//SourceUnit: BttStaking.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @title TRC20 interface
 * @dev see https://github.com/tronprotocol/tips/blob/master/tip-20.md
 */
interface ITRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);
}
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
                set._indexes[lastvalue] = valueIndex;
                // Replace lastvalue's index to valueIndex
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

contract BttStaking is Ownable {
    event StakeIn(address indexed _from, uint256 _value);
    event StakeOut(address indexed _from, uint256 _value);
    event ClaimPendingStakeOut(address indexed _from, uint256 _value);
    event ClaimReward(address indexed _from, uint256 _value);

    // Construct
    uint256 private stakeoutWaitTime;
    address private trc20Token;
    address private dliveAddress;
    uint256 private maxClaimPeriod;

    uint256 private currPayId = 0;
    uint256[] private rewardsPerPayId;
    uint256[] private totalStakesPerPayId;
    uint256[] private updateTimePerPayId;

    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(address tokenAddress, uint256 waitTime, address dAddress, uint256 maxPeriod) {
        trc20Token = tokenAddress;
        stakeoutWaitTime = waitTime;
        dliveAddress = dAddress;
        maxClaimPeriod = maxPeriod;
    }


    struct PendingStakeOut {
        uint256 amount;
        uint256 stakeoutTimestamp; // stakeout timestamp
    }

    struct StakeInfo {
        uint256 amount;
        uint256 payId; // to indicate when user has staked in
    }

    EnumerableSet.AddressSet private stakeSet;  // For iteration
    EnumerableSet.AddressSet private pendingStakeOutSet;  // For iteration
    mapping(address => StakeInfo) private stakes;
    mapping(address => PendingStakeOut) private pendingStakeOuts; // stakes that are available after stake out

    uint256 private totalStakes;
    uint256 private totalPendingStakeOut;
    uint256 private totalReward;

    // Private

    // Stake

    function addStakeholder(address add) private {
        stakeSet.add(add);
    }

    function removeStakeholder(address add) private {
        stakeSet.remove(add);
    }

    // Stake out

    function removePendingStakeout(address add) private {
        pendingStakeOuts[add].amount = 0;
        pendingStakeOutSet.remove(add);
    }

    function addPendingStakeOut(address add) private {
        pendingStakeOutSet.add(add);
    }

    function hasPendingStakeOut(address add) private view returns (bool) {
        return pendingStakeOutSet.contains(add);
    }

    // Public

    function hasPendingReward(address add) public view returns (bool) {
        return stakeSet.contains(add) && payIdOf(add) < currPayId;
    }

    function canStakeIn(address add) public view returns (bool _can, string memory _errorMessage) {
        if (hasPendingStakeOut(add)) {
            return (false, "Cannot stake in with ongoing stake out");
        } else if (hasPendingReward(add)) {
            return (false, "Must claim previous rewards before stake in more");
        }
        return (true, "");
    }

    function canStakeOut(address add, uint256 stake) public view returns (bool _can, string memory _errorMessage) {
        if (!stakeSet.contains(add)) {
            return (false, "Have not staked in");
        } else if (hasPendingStakeOut(add)) {
            return (false, "There is an ongoing stake out");
        } else if (hasPendingReward(add)) {
            return (false, "Must claim previous rewards before stake out");
        } else if (stake > stakeOf(add)) {
            return (false, "Not enough stake");
        }
        return (true, "");
    }

    function canClaimPendingStakeOut(address add) public view returns (bool _can, string memory _errorMessage, bool _hasPendingStakeOut, uint256 _amount, uint256 _stakeoutTimestamp, uint256 _stakeoutAvailableTimestamp) {
        if (!hasPendingStakeOut(add)) {
            return (false, "No pending stakeout", false, 0, 0, 0);
        }
        PendingStakeOut storage c = pendingStakeOuts[add];
        uint256 curTimestamp = block.timestamp;
        uint256 availableTime = c.stakeoutTimestamp + stakeoutWaitTime;
        if (curTimestamp < availableTime) {
            return (false, "Your pending stake out is not ready for claim yet", hasPendingStakeOut(add), c.amount, c.stakeoutTimestamp, availableTime);
        }
        return (true, "", hasPendingStakeOut(add), c.amount, c.stakeoutTimestamp, availableTime);
    }

    function canClaimReward(address add) public view returns (bool _can, string memory _errorMessage, uint256 _reward, uint256 _endPayId, bool _hasMoreToClaim) {
        if (!isStakeholder(add)) {
            return (false, "No reward, have not staked in", 0, 0, false);
        } else if (!hasPendingReward(add)) {
            return (false, "No reward to claim yet", 0, 0, false);
        }
        uint256 payId = payIdOf(add);
        uint256 end = currPayId;
        if ((payId + maxClaimPeriod) < currPayId) {
            end = payId + maxClaimPeriod;
            _hasMoreToClaim = true;
        }
        uint256 total = 0;
        uint256 stake = stakeOf(add);
        for (uint256 i = payId; i < end; i++) {
            total = total + (rewardsPerPayId[i] * stake / totalStakesPerPayId[i]);
        }
        return (true, "", total, end, _hasMoreToClaim);
    }

    // Stake in

    function getTotalStakes() public view returns (uint256) {
        return totalStakes;
    }

    function isStakeholder(address add) public view returns (bool) {
        return stakeSet.contains(add);
    }

    function stakeOf(address add) public view returns (uint256) {
        if (!isStakeholder(add)) {
            return 0;
        }
        // require(stakeSet.exists(add), "No stakein");
        return stakes[add].amount;
    }

    function payIdOf(address add) public view returns (uint256) {
        return stakes[add].payId;
    }

    function stakeIn(uint256 stake) public whenStakeInNotPaused {
        address sender = _msgSender();
        (bool can, string memory errorMessage) = canStakeIn(sender);
        require(can, errorMessage);

        // transfer BTT
        safeTransferFrom(trc20Token, sender, address(this), stake);
        if (!isStakeholder(sender)) {
            addStakeholder(sender);
            stakes[sender].payId = currPayId;
        }
        stakes[sender].amount = stakes[sender].amount + stake;
        totalStakes = totalStakes + stake;

        emit StakeIn(sender, stake);
    }

    // Stake Out

    function stakeOut(uint256 stake) public whenStakeOutNotPaused {
        address sender = _msgSender();
        (bool can, string memory errorMessage) = canStakeOut(sender, stake);
        require(can, errorMessage);
        stakes[sender].amount = stakes[sender].amount - stake;
        if (stakes[sender].amount == 0) {
            removeStakeholder(sender);
        }
        totalStakes = totalStakes - stake;
        addPendingStakeOut(sender);
        pendingStakeOuts[sender] = PendingStakeOut(stake, block.timestamp);
        totalPendingStakeOut = totalPendingStakeOut + stake;
        emit StakeOut(sender, stake);
    }

    function getTotalPendingStakeOut() public view returns (uint256) {
        return totalPendingStakeOut;
    }

    function getStakeOutWaitTime() public view returns (uint256) {
        return stakeoutWaitTime;
    }

    function getMaxClaimPeriod() public view returns (uint256) {
        return maxClaimPeriod;
    }

    // Claim Stake Out

    function claimPendingStakeOut() public payable whenClaimPendingStakeOutNotPaused {
        address payable sender = payable(_msgSender());
        (bool can, string memory errorMessage, , uint256 amount, ,) = canClaimPendingStakeOut(sender);
        require(can, errorMessage);
        removePendingStakeout(sender);
        totalPendingStakeOut = totalPendingStakeOut - amount;
        safeTransferFrom(trc20Token, address(this), sender, amount);
        emit ClaimPendingStakeOut(sender, amount);
    }

    // Claim Reward

    function claimReward() public payable whenClaimRewardNotPaused {
        address payable sender = payable(_msgSender());
        (bool can, string memory errorMessage, uint256 total, uint256 endPayId,) = canClaimReward(sender);
        require(can, errorMessage);
        stakes[sender].payId = endPayId;
        totalReward = totalReward - total;
        safeTransferFrom(trc20Token, address(this), sender, total);
        emit ClaimReward(sender, total);
    }

    // Report reward
    function dliveReportReward(uint256 payId, uint256 amount) public payable whenDliveReportRewardNotPaused {
        require(isDlive(), "Caller is not dlive");
        require(payId == currPayId, "Reporting wrong pay stats");

        // transfer BTT
        safeTransferFrom(trc20Token, _msgSender(), address(this), amount);

        rewardsPerPayId.push(amount);
        updateTimePerPayId.push(block.timestamp);
        totalStakesPerPayId.push(totalStakes);
        currPayId = currPayId + 1;
        totalReward = totalReward + amount;
    }

    function getTotalReward() public view returns (uint256) {
        return totalReward;
    }

    function getCurrPayId() public view returns (uint256) {
        return currPayId;
    }

    function validatePayId(uint256 payId) public view returns (bool) {
        return payId < currPayId;
    }

    function getStatsByPayId(uint256 payId) public view returns (uint256 _reward, uint256 _totalStakes, uint256 _updateTime) {
        require(validatePayId(payId), "Pay ID should be smaller than current Pay ID");
        return (rewardsPerPayId[payId], totalStakesPerPayId[payId], updateTimePerPayId[payId]);
    }

    function getLatestStats() public view returns (uint256 _reward, uint256 _totalStakes, uint256 _updateTime) {
        require(currPayId > 0, "No reward has been distributed");
        return getStatsByPayId(currPayId - 1);
    }

    // Upgrade

    // In case for smart contract upgrade

    function returnTrx() public onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function returnTrc10(trcToken id) public onlyOwner {
        payable(_msgSender()).transferToken(address(this).tokenBalance(id), id);
    }

    function returnTrc20(address token) public onlyOwner {
        safeTransferFrom(token, address(this), _msgSender(), ITRC20(token).balanceOf(address(this)));
    }

    function killMe(address payable to) public onlyOwner {
        selfdestruct(to);
    }

    function setStakeoutWaitTime(uint256 newWatiTime) public onlyOwner {
        stakeoutWaitTime = newWatiTime;
    }

    function setMaxClaimPeriod(uint256 newMax) public onlyOwner {
        maxClaimPeriod = newMax;
    }

    // Access

    function isDlive() public view returns (bool) {
        return _msgSender() == dliveAddress;
    }

    function getDliveAddress() public view returns (address){
        return dliveAddress;
    }

    function setDliveAddress(address newAdd) public onlyOwner {
        require(newAdd != address(0), "New dlive address is the zero address");
        dliveAddress = newAdd;
    }

    // Getters to iterate

    function getStakeAndPayId(address add) public view returns (uint256 _stake, uint256 _payId) {
        return (stakes[add].amount, stakes[add].payId);
    }

    function getPendingStakeOut(address add) public view returns (uint256 _stake, uint256 _stakeoutTimestamp) {
        return (pendingStakeOuts[add].amount, pendingStakeOuts[add].stakeoutTimestamp);
    }

    function stakesCount() public view returns (uint256){
        return stakeSet.length();
    }

    function getStakeAtIndex(uint256 index) public view returns (address _add, uint256 _stake, uint256 _payId) {
        address add = stakeSet.at(index);
        (uint256 stake, uint256 payId) = getStakeAndPayId(add);
        return (add, stake, payId);
    }

    function pendingStakeOutsCount() public view returns (uint256) {
        return pendingStakeOutSet.length();
    }

    function getPendingStakeOutAtIndex(uint256 index) public view returns (address _add, uint256 _stake, uint256 _stakeoutTimestamp) {
        address add = pendingStakeOutSet.at(index);
        (uint256 stake, uint256 timestamp) = getPendingStakeOut(add);
        return (add, stake, timestamp);
    }

    // Pause

    event StakeInPaused(address account);
    event StakeInUnpaused(address account);
    event StakeOutPaused(address account);
    event StakeOutUnpaused(address account);
    event ClaimPendingStakeOutPaused(address account);
    event ClaimPendingStakeOutUnpaused(address account);
    event ClaimRewardPaused(address account);
    event ClaimRewardUnpaused(address account);
    event DliveReportRewardPaused(address account);
    event DliveReportRewardUnpaused(address account);

    bool private _stakeInPaused = true;
    bool private _stakeOutPaused = true;
    bool private _claimPendingStakeOutPaused = true;
    bool private _claimRewardPaused = true;
    bool private _dliveReportRewardPaused = true;

    function stakeInPaused() public view returns (bool) {
        return _stakeInPaused;
    }

    function stakeOutPaused() public view returns (bool) {
        return _stakeOutPaused;
    }

    function claimPendingStakeOutPaused() public view returns (bool) {
        return _claimPendingStakeOutPaused;
    }

    function claimRewardPaused() public view returns (bool) {
        return _claimRewardPaused;
    }

    function dliveReportRewardPaused() public view returns (bool) {
        return _dliveReportRewardPaused;
    }

    modifier whenStakeInNotPaused {
        require(!_stakeInPaused, "Stake In is paused");
        _;
    }

    modifier whenStakeOutNotPaused {
        require(!_stakeOutPaused, "Stake Out is paused");
        _;
    }

    modifier whenClaimPendingStakeOutNotPaused {
        require(!_claimPendingStakeOutPaused, "Claim Pending Stake Out is paused");
        _;
    }

    modifier whenClaimRewardNotPaused {
        require(!_claimRewardPaused, "Claim Reward is paused");
        _;
    }

    modifier whenDliveReportRewardNotPaused {
        require(!_dliveReportRewardPaused, "Dlive Report Reward is paused");
        _;
    }

    function pauseStakeIn() public onlyOwner whenStakeInNotPaused {
        _stakeInPaused = true;
        emit StakeInPaused(_msgSender());
    }

    function pauseStakeOut() public onlyOwner whenStakeOutNotPaused {
        _stakeOutPaused = true;
        emit StakeOutPaused(_msgSender());
    }

    function pauseClaimPendingStakeOut() public onlyOwner whenClaimPendingStakeOutNotPaused {
        _claimPendingStakeOutPaused = true;
        emit ClaimPendingStakeOutPaused(_msgSender());
    }

    function pauseClaimReward() public onlyOwner whenClaimRewardNotPaused {
        _claimRewardPaused = true;
        emit ClaimRewardPaused(_msgSender());
    }

    function pauseDliveReportReward() public onlyOwner whenDliveReportRewardNotPaused {
        _dliveReportRewardPaused = true;
        emit DliveReportRewardPaused(_msgSender());
    }

    function unpauseStakeIn() public onlyOwner {
        require(_stakeInPaused, "Stake In is not paused");
        _stakeInPaused = false;
        emit StakeInUnpaused(_msgSender());
    }

    function unpauseStakeOut() public onlyOwner {
        require(_stakeOutPaused, "Stake Out is not paused");
        _stakeOutPaused = false;
        emit StakeOutUnpaused(_msgSender());
    }

    function unpauseClaimPendingStakeOut() public onlyOwner {
        require(_claimPendingStakeOutPaused, "Claim Pending Stake Out is not paused");
        _claimPendingStakeOutPaused = false;
        emit ClaimPendingStakeOutUnpaused(_msgSender());
    }

    function unpauseClaimReward() public onlyOwner {
        require(_claimRewardPaused, "Claim Reward is not paused");
        _claimRewardPaused = false;
        emit ClaimRewardUnpaused(_msgSender());
    }

    function unpauseDliveReportReward() public onlyOwner {
        require(_dliveReportRewardPaused, "Dlive Report Reward is not paused");
        _dliveReportRewardPaused = false;
        emit DliveReportRewardUnpaused(_msgSender());
    }

    // Migrate from old contract

    bool private migrationCompleted = false;

    function getMigrationCompleted() public view returns (bool) {
        return migrationCompleted;
    }

    function completeMigration() public onlyOwner {
        migrationCompleted = true;
    }

    modifier whenMigrating {
        require(!migrationCompleted, "Migration is complete");
        _;
    }

    function importStake(address add, uint256 stake, uint256 payId) public onlyOwner whenMigrating {
        addStakeholder(add);
        stakes[add] = StakeInfo(stake, payId);
        totalStakes = totalStakes + stake;
    }

    function importPendingStakeOut(address add, uint256 stake, uint256 stakeoutTimestamp) public onlyOwner whenMigrating {
        addPendingStakeOut(add);
        pendingStakeOuts[add] = PendingStakeOut(stake, stakeoutTimestamp);
        totalPendingStakeOut = totalPendingStakeOut + stake;
    }

    function importStats(uint256 payId, uint256 reward, uint256 ts, uint256 updateTimestamp) public onlyOwner whenMigrating {
        require(payId == currPayId, "Importing wrong pay stats");
        rewardsPerPayId.push(reward);
        updateTimePerPayId.push(updateTimestamp);
        totalStakesPerPayId.push(ts);
        currPayId = currPayId + 1;
    }

    function importTotalReward(uint256 tr) public onlyOwner whenMigrating {
        totalReward = tr;
    }

    //TRC20 Helper

    // Helper

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "safe transferFrom failed"
        );
    }

}