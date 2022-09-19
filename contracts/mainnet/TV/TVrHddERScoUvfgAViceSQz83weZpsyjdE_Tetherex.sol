//SourceUnit: Tetherex.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
/**
 * @dev Partial interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract Tetherex {
    using SafeMath for uint256;

    uint256 constant public INVEST_MIN_AMOUNT = 50 * 10 ** 6;
    uint256 constant public MIN_WITHDRAW = 5 * 10 ** 6;
    uint256 constant public BASE_PERCENT = 30;
    uint256[] public REFERRAL_PERCENTS = [60, 20, 10];
    uint256 constant public MARKETING_FEE = 50;
    uint256 constant public PROJECT_FEE = 50;
    uint256 constant public ADMIN_FEE = 10;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public CONTRACT_BALANCE_STEP = 20000 * 10 ** 6;
    uint256 constant public CONTRACT_BALANCE_MAX_PERCENT = 200;
    uint256 constant public TIME_STEP = 1 days;
    uint256 constant public HOLD_TIME_STEP = 3600 * 12;
    uint256 constant public HOLD_BONUS_PERCENT = 1;

    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256 public totalIncomes;

    address public marketingAddress;
    address public projectAddress;
    address public adminAddress;
    address public defaultAddress;
    address public paymentTokenAddress;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
    }

    mapping (address => User) internal users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);
    event DepositLog(
        address user,
        uint256 depositIndex,
        uint256 amount,
        uint256 period,
        uint256 holdPeriods,
        uint256 holdBonus,
        uint256 dividends,
        bool closed
    );

    constructor (
        address marketingAddr,
        address projectAddr,
        address adminAddr,
        address defaultAddr,
        address paymentTokenAddr
    ) {
        require(!isContract(marketingAddr) && !isContract(projectAddr));
        marketingAddress = marketingAddr;
        projectAddress = projectAddr;
        adminAddress = adminAddr;
        defaultAddress = defaultAddr;
        paymentTokenAddress = paymentTokenAddr;
    }

    function invest (address referrer, uint256 amount) public {
        require(amount >= INVEST_MIN_AMOUNT, 'Amount can not be less than minimal investment');
        _takePayment(msg.sender, amount);

        totalIncomes = totalIncomes.add(amount);

        uint256 marketingFee = amount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        _sendPayment(marketingAddress, marketingFee);

        uint256 projectFee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        _sendPayment(projectAddress, projectFee);

        uint256 adminFee = amount.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
        _sendPayment(adminAddress, adminFee);

        emit FeePayed(msg.sender, marketingFee.add(projectFee).add(adminFee));

        User storage user = users[msg.sender];

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        address upline = user.referrer;
        for (uint256 i = 0; i < 3; i++) {
            uint256 refAmount = amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
            if (upline == address(0)) {
                upline = defaultAddress;
            }
            users[upline].bonus = users[upline].bonus.add(refAmount);
            _sendPayment(upline, refAmount);
            emit RefBonus(upline, msg.sender, i, refAmount);
            if (upline != defaultAddress) {
                upline = users[upline].referrer;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(amount, 0, block.timestamp));

        totalInvested = totalInvested.add(amount);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(msg.sender, amount);

    }

    function withdraw() public {
        User storage user = users[msg.sender];
        uint256 percentRate = getContractBalanceRate();
        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256[] memory data = new uint256[](4);
                // data[0] period;
                // data[1] holdPeriods;
                // data[2] holdBonus;
                // data[3] dividends;
            bool closed;
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) { // No more than 200%
                if (user.deposits[i].start > user.checkpoint) {
                    data[0] = block.timestamp.sub(user.deposits[i].start);
                } else {
                    data[0] = block.timestamp.sub(user.checkpoint);
                }
                data[1] = data[0].div(HOLD_TIME_STEP);
                if (data[1] > 0) {
                    data[2] = user.deposits[i].amount
                        .mul(HOLD_BONUS_PERCENT)
                        .div(PERCENTS_DIVIDER)
                        .mul(data[1]);
                }
                data[3] = (user.deposits[i].amount.mul(percentRate).div(PERCENTS_DIVIDER))
                    .mul(data[0])
                    .div(TIME_STEP)
                    .add(data[2]);
                if (user.deposits[i].withdrawn.add(data[3]) > user.deposits[i].amount.mul(2)) {
                    data[3] = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
                }
                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(data[3]); /// changing of storage data
                totalAmount = totalAmount.add(data[3]);
            } else {
                closed = true;
            }
            emit DepositLog(
                msg.sender,
                i,
                user.deposits[i].amount,
                data[0],
                data[1],
                data[2],
                data[3],
                closed
            );
        }

        require(totalAmount > MIN_WITHDRAW, "Amount can not be less than MIN_WITHDRAW");

        uint256 contractBalance = getContractBalance();
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;
        _sendPayment(msg.sender, totalAmount);
        totalWithdrawn = totalWithdrawn.add(totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }

    function getContractBalance() public view returns (uint256) {
        return IERC20(paymentTokenAddress).balanceOf(address(this));
    }

    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalancePercent = totalIncomes.div(CONTRACT_BALANCE_STEP);
        if (contractBalancePercent > CONTRACT_BALANCE_MAX_PERCENT) {
            contractBalancePercent = CONTRACT_BALANCE_MAX_PERCENT;
        }
        return BASE_PERCENT.add(contractBalancePercent);
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
        User memory user = users[userAddress];
        uint256 percentRate = getContractBalanceRate();
        uint256 totalDividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256[] memory data = new uint256[](4);
                // data[0] period;
                // data[1] holdPeriods;
                // data[2] holdBonus;
                // data[3] dividends;
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) { // No more than 200%
                if (user.deposits[i].start > user.checkpoint) {
                    data[0] = block.timestamp.sub(user.deposits[i].start);
                } else {
                    data[0] = block.timestamp.sub(user.checkpoint);
                }
                data[1] = data[0].div(HOLD_TIME_STEP);
                if (data[1] > 0) {
                    data[2] = user.deposits[i].amount
                        .mul(HOLD_BONUS_PERCENT)
                        .div(PERCENTS_DIVIDER)
                        .mul(data[1]);
                }
                data[3] = (user.deposits[i].amount.mul(percentRate).div(PERCENTS_DIVIDER))
                    .mul(data[0])
                    .div(TIME_STEP)
                    .add(data[2]);
                if (user.deposits[i].withdrawn.add(data[3]) > user.deposits[i].amount.mul(2)) {
                    data[3] = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
                }
                /// no update of withdrawn because that is view function
                totalDividends = totalDividends.add(data[3]);
            }
        }
        return totalDividends;
    }

    function getUserCheckpoint(address userAddress) public view returns(uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress) public view returns(uint256) {
        return users[userAddress].bonus;
    }

    function getUserAvailable(address userAddress) public view returns(uint256) {
        return getUserDividends(userAddress);
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        if (user.deposits.length > 0) {
            if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(2)) {
                return true;
            }
        }
        return false;
    }

    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256) {
        User storage user = users[userAddress];

        return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].withdrawn);
        }

        return amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function _takePayment (
        address from, uint256 amount
    ) internal returns (bool) {
        IERC20(paymentTokenAddress).transferFrom(
            from,
            address(this),
            amount
        );
        return true;
    }

    function _sendPayment (
        address to, uint256 amount
    ) internal returns (bool) {
        IERC20(paymentTokenAddress).transfer(
            to,
            amount
        );
        return true;
    }
}