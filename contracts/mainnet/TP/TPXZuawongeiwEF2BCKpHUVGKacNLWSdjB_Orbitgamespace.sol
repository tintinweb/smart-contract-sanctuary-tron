//SourceUnit: orbitgamespace.sol

pragma solidity ^0.5.10;

// sustainable smart contract that gives 4 to 25.5 % ROI daily.
// 
// 100% secure audited smart contract, no back door, highly profitable
// 5 level referral rewards.
// Join now!!!
// 

contract Orbitgamespace {
    //Importing SafeMath
    using SafeMath for uint256;
    // total amount invested in the contract
    uint256 public TotalInvested;
    mapping(address => userst) internal users;
    //base variables
    uint256[] public referralreward = [7, 4, 3, 2, 1];
    //2X investment
	uint256 maxearnings=20;
    // minimum 200trx
	uint256 minimum=200000000;
    //24 hours 86,400 seconds
     uint256 minimumwtime=86400;
    //operator fee
    uint256 internal oppfee;
    //developer fee
    uint256 internal devfee;
    //operator account
    address payable internal opp;
    //dev account
    address payable internal dev;
    //total no of users
    uint256 userno;
    //fee storage
    uint256 oppfeeam;
    uint256 devfeeam;
	//define deposit sructure
	struct deposit {
	    uint256 amount;
		uint256 start;
		uint256 withdrawn;
        uint256 lastaction;
	}
	// define user structure
	struct userst {
	    address payable wallet;
	    deposit[] deposits;
	    address referrer;
	    uint256 refreward;
	    uint256 totalwithdrawn;
	    uint256 lastactions;
	}
	//contract varibles
	constructor() public{
	    //operation fee 9%
	    oppfee=90;
	    //dev fee 7%
	    devfee=70;
	    dev=msg.sender;
	    opp=address(0);
	    userno=0;
	    oppfeeam=0;
	    devfeeam=0;
	    TotalInvested =0;
	}
    //function to deal with deposit.
	function invest(address referrer) public payable returns(bool){
	    require(msg.value>=minimum && msg.sender!=referrer);
        userst storage user = users[msg.sender];
        TotalInvested=TotalInvested.add(msg.value);
        // first time users
        if(users[msg.sender].deposits.length == 0){
            userno=userno+1;
            user.wallet=msg.sender;
            //calculate and add fee
            devfeeam=devfeeam.add((msg.value.div(1000)).mul(devfee));
	        oppfeeam=oppfeeam.add((msg.value.div(1000)).mul(oppfee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.totalwithdrawn=0;
            user.lastactions=block.timestamp;
            user.refreward=0;
            //check if the referrer is valid or not
            if (users[referrer].deposits.length > 0) {
    		    user.referrer = referrer;
    		}
    		else{
    		    user.referrer = address(0);
    		}
        }
        //if user is a re investor
        else{
            //calculate and add fee
            devfeeam=devfeeam.add((msg.value.div(1000)).mul(devfee));
	        oppfeeam=oppfeeam.add((msg.value.div(1000)).mul(oppfee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.lastactions=block.timestamp;
        }
      //paying referrel rewards
      address upline = user.referrer;
    	for (uint256 i = 0; i < referralreward.length; i++) {
    		if (upline != address(0)) {
    		    uint256 amount = msg.value.mul(referralreward[i]).div(100);
				users[upline].refreward = users[upline].refreward.add(amount);
				upline = users[upline].referrer;
    		} else break;
    	}
    	return true;
	}

	//int to string
	function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    //get user data
    function getuser(address uaddr) public view returns(address wallet, address referrer, uint256 refreward, uint256 totalwithdrawn, uint256 noofdeposits, uint256 total, uint256 lastupdate){
	    userst storage user = users[uaddr];
	    wallet=user.wallet;
	    referrer=user.referrer;
	    refreward=user.refreward;
	    totalwithdrawn=user.totalwithdrawn;
	    noofdeposits=user.deposits.length;
	    total=0;
		lastupdate=user.lastactions;
	    for(uint256 i=0; i<noofdeposits; i++){
	        total=total.add(user.deposits[i].amount);
	    }
	}

	//get deposits of an user as a json string.
	function getdeposits(address uaddr) public view returns(string memory s){
	    userst storage user = users[uaddr];
	    bytes memory b;
	    uint256 noofdeposits=user.deposits.length;
	    b = abi.encodePacked("{");
	    b = abi.encodePacked(b,'"result":[');
	    for(uint256 i=0; i<noofdeposits; i++){
	        if(i!=0){
	            b = abi.encodePacked(b,",");
	        }
	        b = abi.encodePacked(b,'{');
	        b = abi.encodePacked(b,'"amount":');
	        b = abi.encodePacked(b,uint2str(user.deposits[i].amount));
	        b = abi.encodePacked(b,",");
	        b = abi.encodePacked(b,'"start":');
	        b = abi.encodePacked(b,uint2str(user.deposits[i].start));
	        b = abi.encodePacked(b,",");
	        b = abi.encodePacked(b,'"withdrawn":');
	        b = abi.encodePacked(b,uint2str(user.deposits[i].withdrawn));
	        b = abi.encodePacked(b,",");
	        b = abi.encodePacked(b,'"lastaction":');
	        b = abi.encodePacked(b,uint2str(user.deposits[i].lastaction));
	        b = abi.encodePacked(b,"}");
	    }
        b = abi.encodePacked(b, "]}");
        s = string(b);
	}

	//shows withdrawable amount.
	function withdrawable(address _address) view public returns(uint256 total, bool status){
        userst storage user = users[_address];
        total=0;
        status=false;
	    uint256 withdrawablebalance=0;
	    for(uint256 i=0; i<user.deposits.length; i++){
	        withdrawablebalance=0;
	        if(block.timestamp > (user.lastactions+minimumwtime)){
	            withdrawablebalance=(user.deposits[i].amount.mul(currentroi(user.deposits[i].lastaction))).mul((block.timestamp.sub(user.deposits[i].start))).div((86400*10000));
	            if(withdrawablebalance > (user.deposits[i].amount.mul(maxearnings)).div(10)){
                    withdrawablebalance=(user.deposits[i].amount.mul(maxearnings)).div(10);
	            }
	            withdrawablebalance=withdrawablebalance.sub(user.deposits[i].withdrawn);
                status=true;
	         }
	        total=total.add(withdrawablebalance);
	    }
	    total=total.add(user.refreward);
	}

 	//shows earnings.
	function earnings(address _address) view public returns(uint256){
        userst storage user = users[_address];
        uint256 total=0;
        uint256 withdrawablebalance=0;
        for(uint256 i=0; i<user.deposits.length; i++){
            withdrawablebalance=0;
            withdrawablebalance=(user.deposits[i].amount.mul(currentroi(user.deposits[i].lastaction))).mul((block.timestamp.sub(user.deposits[i].start))).div((86400*10000));
            if(withdrawablebalance > (user.deposits[i].amount.mul(maxearnings)).div(10)){
            withdrawablebalance=(user.deposits[i].amount.mul(maxearnings)).div(10);
            }
            withdrawablebalance=withdrawablebalance.sub(user.deposits[i].withdrawn);
            total=total.add(withdrawablebalance);
        }
        total=total.add(user.refreward);
        return total;
	}

	//calculate current ROI
	function currentroi(uint256 wtimestamp) view public returns(uint256){
	    uint256 _ROI;
	    _ROI=0;
        if(TotalInvested>15000000000000){
            _ROI=1000;
        }
        else{
	        _ROI=400+((TotalInvested.div(500000000000))*20);
        }
		if(TotalInvested>1000000000000){
		    _ROI=_ROI+50;
		}
		uint256 dayss=(block.timestamp.sub(wtimestamp)).div(86400);
		if(dayss>3 && dayss<7){
		    _ROI=_ROI+50;
		}
        else if(dayss>7 && dayss<15){
            _ROI=_ROI+150;
        }
        else if(dayss>15 && dayss <30 ){
            _ROI=_ROI+500;
        }
         else if(dayss>30){
            _ROI=_ROI+1500;
        }
		return _ROI;
	}

	//function to process withdraw
	function withdraw() public payable returns(bool){
	    userst storage user = users[msg.sender];
	    (uint256 currentbalance, bool withdrawablecondition)=withdrawable(msg.sender);
		require(withdrawablecondition==true);
	    if(withdrawablecondition==true){
	         for(uint256 i=0; i<user.deposits.length; i++){
    	         uint256 withdrawablebalance=0;
    	         if(block.timestamp > (user.deposits[i].lastaction+minimumwtime)){
    	            withdrawablebalance=(user.deposits[i].amount*currentroi(user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].start)/(86400*10000);
    	            if(withdrawablebalance > (user.deposits[i].amount*maxearnings)/10){
                        withdrawablebalance=(user.deposits[i].amount*maxearnings)/10;
    	            }
    	            withdrawablebalance=withdrawablebalance-user.deposits[i].withdrawn;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn.add(withdrawablebalance);
					 user.deposits[i].lastaction=block.timestamp;
    	         }
    	    }
	        user.totalwithdrawn = user.totalwithdrawn.add(currentbalance);
	        user.refreward=0;
			user.lastactions=block.timestamp;
      address self = address(this);
      uint256 effectivebalance=self.balance.sub(devfeeam.add(oppfeeam));
			if (currentbalance>effectivebalance){
			    currentbalance=effectivebalance;
			}
	        msg.sender.transfer(currentbalance);
	        return true;
	    }
	    else{
	        return false;
	    }
	}

	//function to process reinvest
	function reinvest() public payable returns(bool){
	    userst storage user = users[msg.sender];
	    (uint256 currentbalance, bool withdrawablecondition)=withdrawable(msg.sender);
		require(withdrawablecondition==true);
	    if(withdrawablecondition==true){
	         for(uint256 i=0; i<user.deposits.length; i++){
    	         uint256 withdrawablebalance=0;
    	         if(block.timestamp > (user.deposits[i].lastaction+minimumwtime)){
    	            withdrawablebalance=(user.deposits[i].amount*currentroi(user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].start)/(86400*10000);
    	            if(withdrawablebalance > (user.deposits[i].amount*maxearnings)/10){
                        withdrawablebalance=(user.deposits[i].amount*maxearnings)/10;
    	            }
    	            withdrawablebalance=withdrawablebalance-user.deposits[i].withdrawn;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn.add(withdrawablebalance);
		    		 user.deposits[i].lastaction=block.timestamp;
    	         }
    	    }
	        user.totalwithdrawn = user.totalwithdrawn.add(currentbalance);
	        user.refreward=0;
			user.lastactions=block.timestamp;
            user.deposits.push(deposit(currentbalance, block.timestamp, 0, block.timestamp));
	        return true;
	    }
	    else{
	        return false;
	    }
	}

    //get contract info
	function getcontract() view public returns(uint256 balance, uint256 totalinvestment, uint256 totalinvestors){
	    address self = address(this);
        balance=self.balance;
	    totalinvestment=TotalInvested;
	    totalinvestors=userno;
	}

     //check for a valid user
	function uservalid(address walet) view public returns(bool){
        if(users[walet].deposits.length == 0){
        return false;
        }
        else{
            return true;
        }

	}

    //set opp account
	function setopp() public payable returns(bool){
	    if(opp==address(0)){
	        opp=msg.sender;
	        return true;
	    }
	    else{
	        return false;
	    }
	}

	//pay dev fee and operation fee
	function feepay() public payable returns(bool){
        require(msg.sender==dev || msg.sender==opp);
        if(msg.sender==dev){
            dev.transfer(devfeeam);
            devfeeam=0;
            return true;
        }
        else if(msg.sender==opp){
            opp.transfer(oppfeeam);
            oppfeeam=0;
            return true;
        }
        else{
            return false;
        }
    }
    function seefee() public view returns(uint256){
        require(msg.sender==dev || msg.sender==opp);
        if(msg.sender==dev){
            return devfeeam;
        }
        else if(msg.sender==opp){
            return oppfeeam;
        }
        else{
            return 0;
        }
    }
}



// safe math library
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