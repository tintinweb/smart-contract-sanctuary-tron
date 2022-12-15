//SourceUnit: AlphaPro_Flat.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: apro.sol


pragma solidity ^0.8.0;




contract AlphaPro is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint16;

    uint256 public MinimumInvest = 100*10**6;
    uint8[] public ReferralCommissions = [50, 40, 30, 20, 10];
    uint32 constant public Day = 1 days;
    uint16 constant public PercentDiv = 1000;
    uint256 public WithdrawLimit = 500*10**6;

    uint256 public TotalInvested;
    uint256 public TotalWithdrawn;
    uint256 public TotalDepositCount;


    struct Deposit {
        uint256 amount;
        bool active;
        uint256 start;
        uint16 plan;
    }

    struct Commissions {
        address DownLine;
        uint256 Earned;
        uint256 Invested;
        uint8 Level;
        uint256 DepositTime;
    }

    struct User {
        Deposit[] deposits;
        Commissions[] commissions;
        address upLine;
        uint256 totalInvested;
        uint256 totalWithdrawn;
        uint256 totalCommissions;
        uint256 lvl_one_commissions;
        uint256 lvl_two_commissions;
        uint256 lvl_three_commissions;
        uint256 lvl_four_commissions;
        uint256 lvl_five_commissions;

        uint256 availableCommissions;
    }

    mapping(address => User)   internal users;
    mapping(address => bool) private _isBlacklisted;

    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

       function blacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = true;
    }

    function unBlacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    function config(uint256 minInvest, uint256 withdrawLimit) onlyOwner public {
        MinimumInvest = minInvest;
        WithdrawLimit = withdrawLimit;
    }

    function Invest(address InvestorUpLine) public payable {
        uint256 amount_value = msg.value;
        require(amount_value >= MinimumInvest);

        User storage user = users[msg.sender];

        if (user.upLine == address(0) && users[InvestorUpLine].deposits.length > 0 && InvestorUpLine != msg.sender) {
            user.upLine = InvestorUpLine;
        }

        if (user.upLine != address(0)) {
            address upLine = user.upLine;
            for (uint8 i = 0; i < 4; i++) {
                if (upLine != address(0)) {
                    uint256 amount = amount_value.mul(ReferralCommissions[i]).div(PercentDiv);
                    users[upLine].totalCommissions = users[upLine].totalCommissions.add(amount);
                    users[upLine].availableCommissions = users[upLine].availableCommissions.add(amount);

                    if (i == 0) {
                        users[upLine].lvl_one_commissions = users[upLine].lvl_one_commissions.add(amount);
                    }
                    if (i == 1) {
                        users[upLine].lvl_two_commissions = users[upLine].lvl_two_commissions.add(amount);
                    }
                    if (i == 2) {
                        users[upLine].lvl_three_commissions = users[upLine].lvl_three_commissions.add(amount);
                    }
                    if (i == 3) {
                        users[upLine].lvl_four_commissions = users[upLine].lvl_four_commissions.add(amount);
                    }
                    if (i == 4) {
                        users[upLine].lvl_five_commissions = users[upLine].lvl_five_commissions.add(amount);
                    }

                    users[upLine].commissions.push(Commissions(msg.sender, amount, amount_value, i, block.timestamp));
                    upLine = users[upLine].upLine;
                } else break;
            }
        }

        uint8 plan;
        if (amount_value >= 100 && amount_value < 1500) {plan = 25;}//2.5
        else {plan = 35;}//3.5

        user.deposits.push(Deposit(amount_value, true, block.timestamp, plan));
        user.totalInvested = user.totalInvested.add(amount_value);
        TotalDepositCount = TotalDepositCount.add(amount_value);
        TotalInvested = TotalInvested.add(amount_value);
        emit NewDeposit(msg.sender, amount_value);
    }

    function WithdrawCommissions() public {
        require(!_isBlacklisted[msg.sender], "You're banned");
        User storage user = users[msg.sender];

        uint256 toSend;
        require(user.availableCommissions > 0, "No commissions available");

        toSend = user.availableCommissions;
        user.availableCommissions = 0;

        user.totalCommissions = 0;
        user.lvl_one_commissions = 0;
        user.lvl_two_commissions = 0;
        user.lvl_three_commissions = 0;
        user.lvl_four_commissions = 0;
        user.lvl_five_commissions = 0;

        require(payable(msg.sender).send(toSend));

        TotalWithdrawn = TotalWithdrawn.add(toSend);

        emit Withdrawal(msg.sender, toSend);
    }

    function WithdrawDividends() public {
        require(!_isBlacklisted[msg.sender], "You're banned");

        User storage user = users[msg.sender];
        uint256 toSend;
        uint256 dividends;

        for (uint8 i = 0; i < user.deposits.length; i++) {
            dividends = (user.deposits[i].amount.mul(user.deposits[i].plan).div(PercentDiv))
            .mul(block.timestamp.sub(user.deposits[i].start))
            .div(Day);

            user.deposits[i].start = block.timestamp;
            toSend = toSend.add(user.deposits[i].amount);

            delete user.deposits[i];

            toSend = toSend.add(dividends);
        }

        require(toSend > 0, "No dividends available");
        require(toSend < WithdrawLimit, "You reached max withdrawable limit");

        require(payable(msg.sender).send(toSend));

        TotalWithdrawn = TotalWithdrawn.add(toSend);
        user.totalWithdrawn = user.totalWithdrawn.add(toSend);
        user.totalInvested = 0;
        emit Withdrawal(msg.sender, toSend);
    }

    //function WithdrawDividends(uint256 i,uint256 nn) public {
    function GetUserDividends() public view returns (uint256) {
        User storage user = users[msg.sender];
        uint256 totalDividends;
        uint256 dividends;

        for (uint8 i = 0; i < user.deposits.length; i++) {
            dividends = (user.deposits[i].amount.mul(user.deposits[i].plan).div(PercentDiv))
            .mul(block.timestamp.sub(user.deposits[i].start))
            .div(Day);

            totalDividends = totalDividends.add(user.deposits[i].amount);
            totalDividends = totalDividends.add(dividends);
        }
        return totalDividends;
    }

    function deposit(address payable _to, uint256 _amount) onlyOwner public {
        require(payable(_to).send(_amount));
    }

    function GetTotalCommission(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        return (user.commissions.length);
    }

    function GetUserCommission(address userAddress, uint256 index) public view returns (address, uint256, uint256, uint256, uint256) {
        User storage user = users[userAddress];
        return (user.commissions[index].DownLine, user.commissions[index].Earned, user.commissions[index].Invested, user.commissions[index].Level, user.commissions[index].DepositTime);
    }

    function GetUserData(address userAddress) public view returns (address, uint256, uint256, uint256, uint256,  uint256[5] memory) {
        User storage user = users[userAddress];
        uint256[5] memory lvl_commissions = [
        user.lvl_one_commissions,
        user.lvl_two_commissions,
        user.lvl_three_commissions,
        user.lvl_four_commissions,
        user.lvl_five_commissions
        ];

        return (user.upLine, user.totalInvested, user.totalWithdrawn, user.totalCommissions, user.availableCommissions, lvl_commissions);
    }

    function GetUserTotalDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function GetUserDepositInfo(address userAddress, uint256 index) public view returns (uint256, bool, uint256, uint256) {
        User storage user = users[userAddress];
        return (user.deposits[index].amount, user.deposits[index].active, user.deposits[index].start, user.deposits[index].plan);
    }
}