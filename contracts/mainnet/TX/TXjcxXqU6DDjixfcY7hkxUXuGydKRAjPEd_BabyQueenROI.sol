//SourceUnit: BabyQueenROI.sol

pragma solidity 0.5.4;

interface TRC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool); 
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract BabyQueenROI {

	uint64[] public REFERRAL_PERCENTS = [50, 30, 20, 10, 10, 5, 5, 5, 5, 10];
	uint64 constant public PERCENTS_DIVIDER = 1000;
	uint64 constant public TIME_STEP = 1 days;
	uint constant public MIN = 500 * 10 ** 6;

	uint64 public totalUsers;
	uint64 public totalInvested;
	
	address public tronQueen;
	address public babyQueen;

	struct User {
		uint64 invested;
		uint64 withdrawn;
		uint64 dividends;
		uint64 refBonus;
		uint32 depositCheckpoint;
		uint32 withdrawCheckpoint;
		address referrer;
	}

	mapping (address => User) internal users;

	event Newbie(address user, address indexed referrer, uint amount);
	event NewDeposit(address indexed user, address indexed referrer, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event Bonus(address indexed user, uint256 amount);
	event Draw(address indexed winner, uint256 amount, uint256 selectedIndex, uint256 tickets);

    constructor(address _tronQueen, address _babyToken) public {
        require(!isContract(_tronQueen) && isContract(_babyToken));
        
		tronQueen = _tronQueen;
		babyQueen = _babyToken;
        
        users[msg.sender].invested = 1 * 10**6;
        users[msg.sender].depositCheckpoint = uint32(block.timestamp);
        users[msg.sender].withdrawCheckpoint = uint32(block.timestamp);
	}
	
	function() payable external {}

	function invest(uint _amount, address referrer) public {
		require(_amount >= MIN && TRC20(babyQueen).balanceOf(msg.sender) >= _amount && 
		    TRC20(babyQueen).allowance(msg.sender, address(this)) >= _amount);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)){
    	    require(!isContract(msg.sender) && !isContract(referrer));
		    require(users[referrer].invested > 0 && referrer != msg.sender);
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 amount = _amount*REFERRAL_PERCENTS[i]/PERCENTS_DIVIDER;
					users[upline].refBonus += uint64(amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.invested == 0) {
		    user.withdrawCheckpoint = uint32(block.timestamp);
		    user.depositCheckpoint = uint32(block.timestamp);
    		user.invested = uint64(_amount);
			totalUsers += 1;
			emit Newbie(msg.sender, referrer, _amount);
		}else{
            user.dividends += uint64(getUserDividends(msg.sender));
    		user.depositCheckpoint = uint32(block.timestamp);
    		user.invested += uint64(_amount);
		}

		totalInvested = totalInvested+uint64(_amount);
		TRC20(babyQueen).transferFrom(msg.sender, address(this), _amount);
		TRC20(babyQueen).transfer(tronQueen, _amount * 10 / 100);

		emit NewDeposit(msg.sender, user.referrer, _amount);
	}

	function withdraw() public {
		User storage user = users[msg.sender];
		
        require(block.timestamp > user.withdrawCheckpoint + TIME_STEP, "Ops!");
        
		uint64 dividends = user.dividends + uint64(getUserDividends(msg.sender));
		if(dividends+user.withdrawn>user.invested*3) dividends = user.invested*3-user.withdrawn;
		
		require(dividends > 0, "User has no dividends");

		user.withdrawCheckpoint = uint32(block.timestamp);
		user.depositCheckpoint = uint32(block.timestamp);
		user.dividends = 0;
		user.withdrawn += uint64(dividends*7/10);
		TRC20(babyQueen).transfer(msg.sender, dividends*7/10);

		emit Withdrawn(msg.sender, dividends);

	}

	function withdrawBonus() public {
		User storage user = users[msg.sender];
        uint total = user.refBonus;
        user.refBonus = 0;
		TRC20(babyQueen).transfer(msg.sender, total);
        emit Bonus(msg.sender, total);
	}

	function getUserDividends(address userAddress) public view returns (uint) {
		User storage user = users[userAddress];
		return (user.invested * 30 / PERCENTS_DIVIDER)
						*(block.timestamp - (user.depositCheckpoint))
						/(TIME_STEP);
	}
	
	function getUser(address _addr) public view returns (uint64, uint64, uint64, uint64, uint32, uint32, address){
	    return (
	        users[_addr].invested, 
	        users[_addr].withdrawn, 
	        users[_addr].dividends, 
	        users[_addr].refBonus,
	        users[_addr].depositCheckpoint,
	        users[_addr].withdrawCheckpoint,
	        users[_addr].referrer);
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
        uint[] memory d = new uint[](11);
        
        d[0] = u.depositCheckpoint;
        d[1] = u.invested;
        d[2] = 30;
        d[3] = u.withdrawn;
        d[4] = u.dividends + getUserDividends(_addr);
        d[5] = u.withdrawCheckpoint;
        d[6] = u.refBonus;
        d[7] = totalUsers;
        d[8] = TRC20(babyQueen).balanceOf(address(this));
        d[9] = 0;
        d[10] = totalInvested;
        return d;
        
    }

}