//SourceUnit: TronQueen.sol

pragma solidity 0.5.4;

contract TronQueen {

	uint64[] public REFERRAL_PERCENTS = [50, 30, 20, 10, 10, 5, 5, 5, 5, 10];
	uint64 constant public PERCENTS_DIVIDER = 1000;
	uint64 constant public TIME_STEP = 1 days;

	uint64 public totalUsers;
	uint64 public totalInvested;
	
	address payable public adminWallet;
    address payable public marketingAddress;
    address payable public communityWallet;
    address payable public devAddress;
    
    address payable[] public playBag;
    uint public roundIndex = 0;
    uint public drawingCheckPoint = now;

	struct User {
		uint64 invested;
		uint64 withdrawn;
		uint64 dividends;
		uint32 depositCheckpoint;
		uint32 withdrawCheckpoint;
		address payable referrer;
	}

	mapping (address => User) internal users;

	event Newbie(address user, address indexed referrer, uint amount);
	event NewDeposit(address indexed user, address indexed referrer, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event Draw(address indexed winner, uint256 amount, uint256 selectedIndex, uint256 tickets);

	constructor(address payable marketingAddr, address payable communityAddr,  address payable adminAddr, address payable devAddr) public {
        require(!isContract(marketingAddr) &&
        !isContract(communityAddr) &&
        !isContract(devAddr) &&
        !isContract(adminAddr));
        
		marketingAddress = marketingAddr;
        communityWallet = communityAddr;
        devAddress = devAddr;
        adminWallet=adminAddr;
        
        users[msg.sender].invested = 1 trx;
        users[msg.sender].depositCheckpoint = uint32(block.timestamp);
        users[msg.sender].withdrawCheckpoint = uint32(block.timestamp);
	}

	function invest(address payable referrer) public payable {
		require(msg.value >=  200 trx);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)){
    	    require(!isContract(msg.sender) && !isContract(referrer));
		    require(users[referrer].invested > 0 && referrer != msg.sender);
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address payable upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value*REFERRAL_PERCENTS[i]/PERCENTS_DIVIDER;
					upline.transfer(amount);
				// 	emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

		}

		if (user.invested == 0) {
		    user.withdrawCheckpoint = uint32(block.timestamp);
		    user.depositCheckpoint = uint32(block.timestamp);
    		user.invested = uint64(msg.value);
			totalUsers = totalUsers+(1);
			emit Newbie(msg.sender, referrer, msg.value);
		}else{
            user.dividends += uint64(getUserDividends(msg.sender));
    		user.depositCheckpoint = uint32(block.timestamp);
    		user.invested += uint64(msg.value);
		}

		totalInvested = totalInvested+uint64(msg.value);
		
		payAdminOnDep(msg.value);

		emit NewDeposit(msg.sender, user.referrer, msg.value);
	}

	function withdraw() public {
		User storage user = users[msg.sender];
		
        require(block.timestamp > user.withdrawCheckpoint + TIME_STEP, "Ops!");
        
		uint64 dividends = user.dividends + uint64(getUserDividends(msg.sender));
		if(dividends+user.withdrawn>user.invested*3) dividends = user.invested*3-user.withdrawn;
		
		require(dividends > 0, "User has no dividends");

		uint64 contractBalance = uint64(address(this).balance);
		if (contractBalance < dividends) {
			dividends = contractBalance;
		}

		user.withdrawCheckpoint = uint32(block.timestamp);
		user.depositCheckpoint = uint32(block.timestamp);
		user.dividends = 0;
		user.withdrawn += uint64(dividends*7/10);

		msg.sender.transfer(dividends*7/10);
		
		payAdminOnWithdrawal(dividends);

		emit Withdrawn(msg.sender, dividends);

	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getContractBalanceRate() public view returns (uint64) {
		uint64 contractBalance = uint64(address(this).balance);
		uint64 contractBalancePercent = contractBalance/(1000000 trx);
		if(contractBalancePercent > 10) contractBalancePercent = 10;
		return (contractBalancePercent);
	}

	function getUserPercentRate(address userAddress) public view returns (uint64) {
		User storage user = users[userAddress];

		uint64 contractBalanceRate = getContractBalanceRate();
		uint timeMultiplier = (now-(user.withdrawCheckpoint))/(TIME_STEP);
		timeMultiplier = timeMultiplier > 20 ? 20 : timeMultiplier;
		return uint64(20 + contractBalanceRate + (timeMultiplier));
	}

	function getUserDividends(address userAddress) public view returns (uint) {
		User storage user = users[userAddress];

		uint256 userPercentRate = getUserPercentRate(userAddress);

		return (user.invested * (userPercentRate) / (PERCENTS_DIVIDER))
						*(block.timestamp - (user.depositCheckpoint))
						/(TIME_STEP);
	}
	
	function getUser(address _addr) public view returns (uint64, uint64, uint64, uint32, uint32, address payable){
	    return (
	        users[_addr].invested, 
	        users[_addr].withdrawn, 
	        users[_addr].dividends, 
	        users[_addr].depositCheckpoint,
	        users[_addr].withdrawCheckpoint,
	        users[_addr].referrer);
	}
	
    function payAdminOnDep(uint _amount) private {
        marketingAddress.transfer(_amount*3/100);
        devAddress.transfer(_amount*3/100);
        communityWallet.transfer(_amount*3/100);
        adminWallet.transfer(_amount/100);
    }
    
    function payAdminOnWithdrawal(uint _amount) private {
        uint fee = _amount*2/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) marketingAddress.transfer(fee);
        fee = _amount*2/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) devAddress.transfer(fee);
        fee = _amount*2/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) communityWallet.transfer(fee);
        fee = _amount*1/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) adminWallet.transfer(fee);
    }
    
    function payAdminOnLottery(uint _amount) private {
        uint fee = _amount*6/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) marketingAddress.transfer(fee);
        fee = _amount*6/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) devAddress.transfer(fee);
        fee = _amount*6/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) communityWallet.transfer(fee);
        fee = _amount*2/100;
        if(fee > address(this).balance) fee=address(this).balance;
        if(fee>0) adminWallet.transfer(fee);
    }

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function getData(address _addr) external view returns ( uint[] memory data ){
    
        User memory u = users[_addr];
        uint[] memory d = new uint[](15);
        
        d[0] = u.depositCheckpoint;
        d[1] = u.invested;
        d[2] = getUserPercentRate(_addr);
        d[3] = u.withdrawn;
        d[4] = u.dividends + getUserDividends(_addr);
        d[5] = u.withdrawCheckpoint;
        d[6] = totalUsers;
        d[7] = totalInvested;
        d[8] = getContractBalanceRate();
        d[9] = getContractBalance();
        d[10] = drawingCheckPoint;
        d[11] = getCurrentRoundTickets();
        d[12] = 0;
        d[13] = 0;
        d[14] = getUserTicketsAmount(_addr);
        return d;
        
    }
    
    //----------------------------
    //--------LOttery-------------
    
    function participate(uint _amount) external payable {
        
        require(msg.value >= _amount * 50 trx);
        require(users[msg.sender].invested > 0);//Not registered
        for(uint i=0; i< _amount; i++){
            playBag.push(msg.sender);
        }
    }
    
    function draw() public {
        require(block.timestamp > drawingCheckPoint + TIME_STEP);
        uint tickets = getCurrentRoundTickets();
        require(tickets > 0, "Bag is empty");
        uint winner = roundIndex + generateRandomNumber() % tickets;
        uint amount = getCurrentRoundAmount();
        playBag[winner].transfer(amount*30/100);
        payAdminOnLottery(amount);
        drawingCheckPoint = block.timestamp;
        roundIndex = playBag.length;
        emit Draw(playBag[winner], amount, winner, tickets);
    }
    
    function generateRandomNumber() private view returns(uint) {
        return uint(keccak256(abi.encode(block.difficulty, now, playBag)));
    }
    
    function getCurrentRoundTickets() public view returns(uint){
        return playBag.length-(roundIndex);
    }
    
    function getCurrentRoundAmount() public view returns(uint){
        return getCurrentRoundTickets() * 50 trx;
    }
    
    function getUserTicketsAmount(address _addr) public view returns(uint){
        uint count = 0;
        for (uint i = roundIndex; i < playBag.length; i++){
            if(playBag[i] == _addr){
                count++;
            }
        }
        return count;
    }

}