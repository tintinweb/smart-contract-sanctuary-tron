//SourceUnit: tron_bulls.sol

pragma solidity 0.5.4;

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

contract TronBulls {
    using SafeMath for uint256;

    uint256 public constant INVEST_MIN_AMOUNT = 500 trx;
    uint256 public constant BASE_PERCENT = 100;
    uint16[] public REFERRAL_PERCENTS = [800, 400, 200, 100, 100];
    uint16 public constant MAX_CONTRACT_PERCENT = 100;
    uint16 public constant MAX_LEADER_PERCENT = 50;
    uint16 public constant MAX_HOLD_PERCENT = 100;
    uint16 public constant MAX_COMMUNITY_PERCENT = 50;
    uint16 public constant PERCENTS_DIVIDER = 10000;
    uint256 public constant CONTRACT_BALANCE_STEP = 1000000000 trx;
    uint256 public constant LEADER_BONUS_STEP = 1000000000 trx;
    uint256 public constant COMMUNITY_BONUS_STEP = 10000000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public totalDeposits;
    address payable public constant developerAddress = address(0xcd7c0f0C9B3e2cD5F0768Ccc8bf342Ad6275d8d1);
    uint256[10]  networkValues = [500, 200, 200, 300, 250, 100, 200, 100, 100, 100];
    address payable[10] public networkAddresses = [
        address(0xE7D1DD687B7A9C82f4AEbB3bb978Bc8e096bAD3F),
        address(0xB414041E67F162Da0Ed9c8A3F48D470654755175),
        address(0x4C1B6A7945521120d53C5ddDA95fa8E96c862cF3),
        address(0xC6a40B7A84a2F8E5937b8513CC1697B9DD612603),
        address(0x8bFb8049a77C69fA53AaB82f733725523D13B9A4),
        address(0xA3c9f3098fa58603C7B389b096aDDe595AD1a4B3),
        address(0xC85b475373eF220a3c27b9dBeC71B8377f2d85ef),
        address(0xE0d5CA726fc49bC2b10D4C876703A7483AE6e5A8),
        address(0x7562a3712b224ABcaeB31d21f1EaD99689ae0C27),
        address(0x2f3B5DBcae72b62224cC661eFF062fCE732a6985)
    ];

    uint256 public contractPercent;

    uint256 public totalRefBonus;

    struct Deposit {
        uint64 amount;
        uint64 withdrawn;
        uint32 start;
    }

    struct User {
        Deposit[] deposits;
        uint32 checkpoint;
        address referrer;
        uint64 bonus;
        uint24[5] refs;
    }

    mapping(address => User) internal users;
    mapping(uint256 => uint256) internal turnover;

    constructor() public {
        contractPercent = address(this).balance;
    }


    function getContractBalanceRate() public view returns (uint256) {
        uint256 contractBalance = address(this).balance;
        uint256 contractBalancePercent = BASE_PERCENT.add(
            contractBalance.div(CONTRACT_BALANCE_STEP).mul(20)
        );

        if (contractBalancePercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            return contractBalancePercent;
        } else {
            return BASE_PERCENT.add(MAX_CONTRACT_PERCENT);
        }
    }

    function getLeaderBonusRate() public view returns (uint256) {
        uint256 leaderBonusPercent = totalRefBonus.div(LEADER_BONUS_STEP).mul(10);

        if (leaderBonusPercent < MAX_LEADER_PERCENT) {
            return leaderBonusPercent;
        } else {
            return MAX_LEADER_PERCENT;
        }
    }

    function getCommunityBonusRate() public view returns (uint256) {
        uint256 communityBonusRate = totalDeposits
            .div(COMMUNITY_BONUS_STEP)
            .mul(10);

        if (communityBonusRate < MAX_COMMUNITY_PERCENT) {
            return communityBonusRate;
        } else {
            return MAX_COMMUNITY_PERCENT;
        }
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 userPercentRate = getUserPercentRate(msg.sender);
        uint256 communityBonus = getCommunityBonusRate();
        uint256 leaderbonus = getLeaderBonusRate();

        uint256 totalAmount;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate + communityBonus + leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate + communityBonus + leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(2)) {
                    dividends = (uint256(user.deposits[i].amount).mul(2)).sub(uint256(user.deposits[i].withdrawn));
                }

                user.deposits[i].withdrawn = uint64(uint256(user.deposits[i].withdrawn).add(dividends)); /// changing of storage data
                totalAmount = totalAmount.add(dividends);

            }
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = uint32(block.timestamp);

        (bool success,) = msg.sender.call.value(totalAmount)("");
        require(success, "Transfer failed");
    }

    function getUserPercentRate(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        if (isActive(userAddress)) {
            uint256 timeMultiplier = (block.timestamp.sub(uint256(user.checkpoint))).div(TIME_STEP.div(2)).mul(5);
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }
            return contractPercent.add(timeMultiplier);
        } else {
            return contractPercent;
        }
    }

    function getUserAvailable(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);
        uint256 communityBonus = getCommunityBonusRate();
        uint256 leaderbonus = getLeaderBonusRate();

        uint256 totalDividends;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            if (uint256(user.deposits[i].withdrawn) < uint256(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate + communityBonus + leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint256(user.deposits[i].amount).mul(userPercentRate + communityBonus + leaderbonus).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint256(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint256(user.deposits[i].withdrawn).add(dividends) > uint256(user.deposits[i].amount).mul(2)) {
                    dividends = (uint256(user.deposits[i].amount).mul(2)).sub(uint256(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);
            }

        }

        return totalDividends;
    }

    function invest(address referrer) public payable {
        require(
            msg.value >= INVEST_MIN_AMOUNT,
            "Bad Deposit"
        );

        User storage user = users[msg.sender];

        uint256 msgValue = msg.value;
        uint256 developerFee = msgValue.mul(500).div(PERCENTS_DIVIDER);
        uint256[] memory network = new uint256[](10);

        for (uint8 i = 0; i < 10; i++) {
            network[i] = msgValue.mul(networkValues[i]).div(PERCENTS_DIVIDER);
        }

        (bool success,) = developerAddress.call.value(developerFee)("");

        require(success, "Developer fee transfer failed");

        for (uint8 i = 0; i < networkAddresses.length; i++) {
            (success,) = networkAddresses[i].call.value(network[i])("");
            require(success, "Network transfer failed");
        }


        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint8 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = msgValue.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);

                    if (amount > 0) {
                        (success,) = address(uint160(upline)).call.value(amount)("");
                        require(success, "Referral bonus transfer failed");

                        users[upline].bonus = uint64(uint256(users[upline].bonus).add(amount));

                        totalRefBonus = totalRefBonus.add(amount);
                    }

                    users[upline].refs[i]++;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint32(block.timestamp);
        }

        user.deposits.push(Deposit(uint64(msgValue), 0, uint32(block.timestamp)));

        if (contractPercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            uint256 contractPercentNew = getContractBalanceRate();
            if (contractPercentNew > contractPercent) {
                contractPercent = contractPercentNew;
            }
        }
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && uint256(user.deposits[user.deposits.length - 1].withdrawn) < uint256(user.deposits[user.deposits.length - 1].amount).mul(2);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserLastDeposit(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        return user.checkpoint;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint256(user.deposits[i].amount));
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 amount = user.bonus;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint256(user.deposits[i].withdrawn));
        }

        return amount;
    }




    function getUserDeposits(address userAddress, uint256 last, uint256 first) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        User storage user = users[userAddress];

        uint256 count = first.sub(last);
        if (count > user.deposits.length) {
            count = user.deposits.length;
        }

        uint256[] memory amount = new uint256[](count);
        uint256[] memory withdrawn = new uint256[](count);
        uint256[] memory refback = new uint256[](count);
        uint256[] memory start = new uint256[](count);

        uint16 index = 0;
        for (uint256 i = first; i > last; i--) {
            amount[index] = uint256(user.deposits[i - 1].amount);
            withdrawn[index] = uint256(user.deposits[i - 1].withdrawn);
            start[index] = uint256(user.deposits[i - 1].start);
            index++;
        }

        return (amount, withdrawn, refback, start);
    }



    function getUserStats(address userAddress) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 userPerc = getUserPercentRate(userAddress);
        uint256 userAvailable = getUserAvailable(userAddress);
        uint256 userDepsTotal = getUserTotalDeposits(userAddress);
        uint256 userDeposits = getUserAmountOfDeposits(userAddress);
        uint256 userWithdrawn = getUserTotalWithdrawn(userAddress);

        return (userPerc, userAvailable, userDepsTotal, userDeposits, userWithdrawn);
    }

    function getUserReferralsStats(address userAddress) public view returns (address, uint64, uint24[5] memory) {
        User storage user = users[userAddress];

        return (user.referrer, user.bonus, user.refs);
    }
}