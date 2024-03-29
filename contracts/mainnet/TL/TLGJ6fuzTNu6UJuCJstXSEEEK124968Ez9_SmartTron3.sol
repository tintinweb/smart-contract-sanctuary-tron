//SourceUnit: RR.sol


pragma solidity 0.5.8;

contract SmartTron3 {
    using SafeMath for uint256;

    uint256 constant public MIN_INVEST = 100 trx;
    uint256 constant public MIN_WITHDRAW = 100 trx;
    uint256 constant public MAX_DEPOSITS = 100;
    uint256 constant public BASE_PERCENT = 150;
    uint256[] public REFERRAL_PERCENTS = [500, 200, 100];
    uint256 constant public ADVERTISING_FEE = 700;
    uint256 constant public PROJECT_FEE = 300;
    uint256 constant public HOLD_MULTIPLIER = 15;
    uint256 constant public MULTIPLIER = 21;
    uint256 constant public MULTIPLIER_DIVIDER = 10;
    uint256 constant public PERCENTS_DIVIDER = 10000;
    uint256 constant public BALANCE_STEP = 1000000 trx;
    uint256 constant public TIME_STEP = 1 days;

    uint256 public totalDeposits;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;

    address payable public advertisingAddress;
    address payable public projectAddress;

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
        uint256 refs1;
        uint256 refs2;
        uint256 refs3;
    }

    mapping (address => User) internal users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable advertisingAddr, address payable projectAddr) public {
        require(!isContract(advertisingAddr) && !isContract(projectAddr));
        advertisingAddress = advertisingAddr;
        projectAddress = projectAddr;
    }

    function invest(address referrer) public payable {
        require(msg.value >= MIN_INVEST, "Minimum invest is 100 TRX");

        User storage user = users[msg.sender];

        require(user.deposits.length < MAX_DEPOSITS, "Maximum 100 deposits per address");

        advertisingAddress.transfer(msg.value.mul(ADVERTISING_FEE).div(PERCENTS_DIVIDER));
        projectAddress.transfer(msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
        emit FeePayed(msg.sender, msg.value.mul(ADVERTISING_FEE.add(PROJECT_FEE)).div(PERCENTS_DIVIDER));

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(amount);
                    if (i == 0) {
                        users[upline].refs1 = users[upline].refs1.add(amount);
                    }
                    if (i == 1) {
                        users[upline].refs2 = users[upline].refs2.add(amount);
                    }
                    if (i == 2) {
                        users[upline].refs3 = users[upline].refs3.add(amount);
                    }
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(msg.value, 0, block.timestamp));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(msg.sender, msg.value);

    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 userPercentRate = getUserPercentRate(msg.sender);

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);

                } else {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);

                }

                if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)) {
                    dividends = (user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)).sub(user.deposits[i].withdrawn);
                }

                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends);
                totalAmount = totalAmount.add(dividends);

            }
        }

        if (user.bonus > 0) {
            totalAmount = totalAmount.add(user.bonus);
            user.bonus = 0;
        }

        require(totalAmount > MIN_WITHDRAW, "Minimum withdraw is 1 TRX");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = block.timestamp;

        msg.sender.transfer(totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);

    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserPercentRate(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 userWithdrawn;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            userWithdrawn = userWithdrawn.add(user.deposits[i].withdrawn);
        }

        if (isActive(userAddress)) {
            if (userWithdrawn > 0) {
                return 0;
            } else {
                uint256 timeMultiplier = (now.sub(user.checkpoint)).div(TIME_STEP);
                return timeMultiplier.mul(HOLD_MULTIPLIER);
            }

        } else {
            return 0;
        }
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getMainStats() public view returns (uint256, uint256, uint256, uint256) {
        return (totalInvested, totalWithdrawn, totalDeposits, getContractBalance());
    }

    function getUserStats(address userAddress) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        User storage user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);

        uint256 userAvailable = user.bonus;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);

                } else {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);

                }

                if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)) {
                    dividends = (user.deposits[i].amount.mul(MULTIPLIER).div(MULTIPLIER_DIVIDER)).sub(user.deposits[i].withdrawn);
                }

                userAvailable = userAvailable.add(dividends);

            }

        }

        uint256 userDeposited;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            userDeposited = userDeposited.add(user.deposits[i].amount);
        }

        uint256 userDeposits = user.deposits.length;

        uint256 userLastDepositDate;
        if (userDeposits > 0) {
            userLastDepositDate = user.deposits[userDeposits-1].start;
        }

        uint256 userWithdrawn;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            userWithdrawn = userWithdrawn.add(user.deposits[i].withdrawn);
        }
        userWithdrawn = userWithdrawn.add(user.refs1).add(user.refs2).add(user.refs3).sub(user.bonus);

        return (userPercentRate, userAvailable, userDeposited, userDeposits, userLastDepositDate, userWithdrawn);
    }

    function getUserRefInfo(address userAddress) public view returns (address, uint256, uint256, uint256) {
        User storage user = users[userAddress];

        return (user.referrer, user.refs1, user.refs2, user.refs3);
    }

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