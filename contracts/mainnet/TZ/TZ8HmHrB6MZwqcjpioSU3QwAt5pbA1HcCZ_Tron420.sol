//SourceUnit: Tron420.sol

pragma solidity 0.5.10;

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

contract Tron420 {
    using SafeMath for uint;
    uint constant public DEPOSITS_MAX = 100;
    uint constant public INVEST_MIN_AMOUNT = 500e6;
    uint constant public INVEST_MAX_AMOUNT = 2000000e6;
    uint constant public MAX_ACTIVE_DEPOSITS = 2000000e6;
    uint constant public DAILY_LIMIT = 250000e6;
    uint constant public MAX_PROFIT = 42000;
    uint constant public WITHDRAW_MIN_AMOUNT = 200e6;
    uint constant public WITHDRAW_RETURN = 2500;
    uint constant public BASE_PERCENT = 250;
    uint[] public REFERRAL_PERCENTS = [1000, 500, 300, 200];
    uint constant public ADMIN_FEE = 800; 
	uint constant public DEV_FEE = 100;
    uint constant public PERCENTS_DIVIDER = 10000;
    uint constant public TIME_STEP = 1 days;

    address payable public ownerAddress;
	address payable public dev1Address;
    address payable public dev2Address;

    uint public totalInvested;
    uint public totalUsers;
    uint public totalDeposits;
    uint public totalWithdrawn;
    uint public contractPercent;
    uint public totalRefBonus;
    uint256 public startDate;
    
    struct Deposit {
        uint amount;
        uint withdrawn;
        uint start;
    }

    struct User {
        Deposit[] deposits;
        uint checkpoint;
        address referrer;
        uint bonus;
        uint totalBonus;
        uint24[4] refs;
        uint24[4] levels;
        uint withdrawn;
    }

    mapping (address => User) internal users;
    mapping (uint => mapping(address => uint)) public dLimit;
    event Newbie(address indexed user, address indexed parent);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event FeePayed(address indexed user, uint totalAmount);

    function() payable external {
    }

    constructor(address payable owner, address payable dev1, address payable dev2) public {
        require(!isContract(owner) && !isContract(dev1) && !isContract(dev2));
        ownerAddress = owner;
        dev1Address = dev1;
        dev2Address = dev2;
        startDate = uint(1664420400); //Thu Sep 29 2022 03:00:00 GMT+0000
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function withdraw() public {
        require(block.timestamp > startDate, "contract does not launch yet");
        User storage user = users[msg.sender];

        require(user.checkpoint + TIME_STEP < block.timestamp , "withdraw allowed only once a day" );
        uint referralBonus = getUserReferralBonus(msg.sender);

        uint totalAmount;
        uint dividends;

        for (uint i = 0; i < user.deposits.length; i++) {

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint(user.deposits[i].amount).mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint(user.deposits[i].amount).mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);
                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)) {
                    dividends = (uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)).sub(uint(user.deposits[i].withdrawn));
                }

                user.deposits[i].withdrawn = uint(uint(user.deposits[i].withdrawn).add(dividends)); /// changing of storage data
                totalAmount = totalAmount.add(dividends);

            }
        }

        if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}


        if(dLimit[cDay()][msg.sender] + totalAmount > DAILY_LIMIT){
            user.bonus = uint(dLimit[cDay()][msg.sender].add(totalAmount).sub(DAILY_LIMIT));
            totalAmount = DAILY_LIMIT.sub(dLimit[cDay()][msg.sender]);
        }
        require(totalAmount > WITHDRAW_MIN_AMOUNT, "The minimum withdrawable amount is 200 TRX");
        dLimit[cDay()][msg.sender] = dLimit[cDay()][msg.sender].add(totalAmount);

        uint contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            user.bonus = user.bonus.add(totalAmount.sub(contractBalance));
            totalAmount = contractBalance;
        }
        
        user.checkpoint = uint(block.timestamp);

        totalAmount = totalAmount.sub(totalAmount.mul(WITHDRAW_RETURN).div(PERCENTS_DIVIDER));

        user.withdrawn = user.withdrawn.add(totalAmount);
        msg.sender.transfer(totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);


        emit Withdrawn(msg.sender, totalAmount);
    }

    function getUserAvailable(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint referralBonus = getUserReferralBonus(userAddress);

        uint totalDividends;
        uint dividends;

        for (uint i = 0; i < user.deposits.length; i++) {

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)) {

                if (user.deposits[i].start > user.checkpoint) {
                    dividends = (uint(user.deposits[i].amount).mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {
                    dividends = (uint(user.deposits[i].amount).mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)) {
                    dividends = (uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)).sub(uint(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);
            }

        }
        
        return referralBonus.add(totalDividends);
    }
    
    function invest(address referrer) public payable {
        require(block.timestamp > startDate, "contract does not launch yet");
        uint msgValue = msg.value;
        require(msgValue >= INVEST_MIN_AMOUNT && msgValue <= INVEST_MAX_AMOUNT, "Bad Deposit");
        require(msgValue.add(getUserTotalActiveDeposits(msg.sender)) <= MAX_ACTIVE_DEPOSITS, "Bad Deposit");

        User storage user = users[msg.sender];

        require(user.deposits.length < DEPOSITS_MAX, "Maximum 100 deposits from address");


        uint adminFee = msgValue.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
		uint devFee = msgValue.mul(DEV_FEE).div(PERCENTS_DIVIDER);

        ownerAddress.transfer(adminFee);
        dev1Address.transfer(devFee);
        dev2Address.transfer(devFee);
        emit FeePayed(msg.sender, adminFee.add(devFee.mul(2)));

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
            }
            address upline = user.referrer;
			for (uint i = 0; i < 4; i++) {
				if (upline != address(0)) {
					users[upline].levels[i]++;
					upline = users[upline].referrer;
				} else break;
			}
        }

        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint i = 0; i < 4; i++) {
                if (upline != address(0)) {
                    uint amount = msgValue.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    if (amount > 0) {
                        users[upline].bonus = uint(uint(users[upline].bonus).add(amount));
                        users[upline].totalBonus = uint(uint(users[upline].totalBonus).add(amount));
                        totalRefBonus = totalRefBonus.add(amount);
                        emit RefBonus(upline, msg.sender, i, amount);
                    }
                    users[upline].refs[i]++;
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint(block.timestamp);
            totalUsers++;
            emit Newbie(msg.sender,user.referrer);
        }

        user.deposits.push(Deposit(uint(msgValue), 0, uint(block.timestamp)));

        totalInvested = totalInvested.add(msgValue);
        totalDeposits++;

        emit NewDeposit(msg.sender, msgValue);
    }

    function cDay() public view returns(uint) {
		return (block.timestamp.div(TIME_STEP));
	}

    function getUserDailyLimit(address _user) public view returns(uint) {
		return dLimit[cDay()][_user];
	}

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && uint(user.deposits[user.deposits.length-1].withdrawn) < uint(user.deposits[user.deposits.length-1].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint) {
        return users[userAddress].deposits.length;
    }
    
    function getUserCheckpoint(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        return user.checkpoint;
    }

    function getUserReferralBonus(address userAddress) public view returns(uint) {
		return users[userAddress].bonus;
	}

    function getUserDownlineCount(address userAddress) public view returns(uint24[4] memory levels) {
		return (users[userAddress].levels);
	}

    function getUserTotalDeposits(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        uint amount;
        for (uint i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint(user.deposits[i].amount));
        }
        return amount;
    }

    function getUserTotalActiveDeposits(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        uint amount;
        for (uint i = 0; i < user.deposits.length; i++) {
            if(uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(MAX_PROFIT).div(PERCENTS_DIVIDER)){
                amount = amount.add(uint(user.deposits[i].amount));
            }
        }
        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint) {
        return users[userAddress].withdrawn;
    }

    function getUserDeposits(address userAddress, uint last, uint first) public view returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory) {
        User storage user = users[userAddress];

        uint count = first.sub(last);
        if (count > user.deposits.length) {
            count = user.deposits.length;
        }

        uint[] memory amount = new uint[](count);
        uint[] memory withdrawn = new uint[](count);
        uint[] memory refback = new uint[](count);
        uint[] memory start = new uint[](count);

        uint index = 0;
        for (uint i = first; i > last; i--) {
            amount[index] = uint(user.deposits[i-1].amount);
            withdrawn[index] = uint(user.deposits[i-1].withdrawn);
            start[index] = uint(user.deposits[i-1].start);
            index++;
        }

        return (amount, withdrawn, refback, start);
    }

    function getSiteStats() public view returns (uint, uint, uint, uint, uint) {
        return (totalInvested, totalDeposits, address(this).balance, contractPercent, totalUsers);
    }

    function getUserStats(address userAddress) public view returns (uint, uint, uint, uint) {
        uint userAvailable = getUserAvailable(userAddress);
        uint userDepsTotal = getUserTotalDeposits(userAddress);
        uint userActiveDeposit = getUserTotalActiveDeposits(userAddress);
        uint userWithdrawn = getUserTotalWithdrawn(userAddress);

        return (userAvailable, userDepsTotal, userActiveDeposit, userWithdrawn);
    }

    function getUserReferralsStats(address userAddress) public view returns (address, uint, uint24[4] memory, uint24[4] memory, uint) {
        User storage user = users[userAddress];

        return (user.referrer, user.bonus, user.refs, users[userAddress].levels, user.totalBonus);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}