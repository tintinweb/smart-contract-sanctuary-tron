//SourceUnit: contract.sol

//Tronrevival Sustainable secure smart contract 
//https://tronrevival.org/
// By interacting with this contract you are agreeing to the terms that you have read, understand, and accept the working of this contract. 
// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.7;

//contract name
contract Tronrevival {
	// total amount invested in this contract
	uint256 public total_invested;
	//mapp the address to user data
    mapping(address => user_stuct) public users;
    //contract fixed variables
    uint256 constant minimum_deposit_1 = 300_000_000;
    uint256 constant minimum_deposit_2 = 1_000_000_000;
    uint256 constant minimum_deposit_3 = 3_000_000_000;
    uint256 constant minimum_deposit_4 = 10_000_000_000;
    uint256 constant bonus_bal_at = 1_000_000_000_000;
    uint256[] public referral_rewards = [15, 2, 1, 1];
    address payable public team;
    address payable public team_2;
    address payable public dev;
    uint256 public dev_fee;
    uint256 public team_fee;
    uint256 public fee_avilability=0;
    // No of users
    uint256 no_of_users;
    //contract team fee
    uint256 immutable marketing_fee;
    ///devloper fee
    uint256 immutable developer_fee;
    
    //deposit array
	struct deposit {
		uint256 amount;
		uint256 start;
		uint256 withdrawn;
		uint256 lastaction;
	}
	
	//user data structure
	struct user_stuct {
	    address payable wallet;
	    deposit[] deposits;
	    address referrer;
	    uint256 no_of_referals;
	    uint256 referral_reward;
	    uint256 total_withdrawn;
	    uint256 plan;
	    uint256 lastaction;
	    uint256 contract_balance_update;
	    uint256 users_update;
	    uint256 total_invested_by_user;
	}
	
	//values for the start of the contracts
	constructor(){
	    marketing_fee=80;
	    developer_fee=80;
	    dev=payable(msg.sender);
	    team=payable(address(0));
	    team_2==payable(address(0));
	    no_of_users=0;
	    total_invested =0;
	    dev_fee=0;
	    team_fee=0;
	}
	
	//function for plan 1 users
	function user_deposit_plan_1(address referrer) public payable returns(bool){
	    require(msg.value>=minimum_deposit_1);
        user_stuct storage user = users[msg.sender];
        total_invested=total_invested+msg.value;
        // first time users
        if(users[msg.sender].deposits.length == 0){
            no_of_users = no_of_users+1;
            user.wallet = payable(msg.sender);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.total_withdrawn = 0;
            user.referral_reward = 0;
            user.users_update = (no_of_users)/1000;
	        user.contract_balance_update = (address(this).balance)/bonus_bal_at;
	        user.total_invested_by_user = msg.value;
            user.plan=1;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
    			user.referrer = referrer;
            }
    		else{
    		    user.referrer = address(0);
    		}
    		user.lastaction = block.timestamp;
        }
        //existing users
        else{
            require(user.plan==1);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
	        user.total_invested_by_user = user.total_invested_by_user+msg.value;
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.lastaction = block.timestamp;
        }
        //paying rewards
        address upline = user.referrer;
    	for (uint256 i = 0; i < 4; i++) {
    		if (upline != address(0)) {
    		    if(i==0){
    		        users[upline].no_of_referals = users[upline].no_of_referals+1;
    		    }
    		    uint256 amount = msg.value*(referral_rewards[i])/(100);
				users[upline].referral_reward = users[upline].referral_reward+(amount);
				upline = users[upline].referrer;
    		}
    		else break;
    	}
    	return true;
	}

	//function for plan 2 users
	function user_deposit_plan_2(address referrer) public payable returns(bool){
	    require(msg.value>=minimum_deposit_2);
        user_stuct storage user = users[msg.sender];
        total_invested = total_invested+msg.value;
        // first time users
        if(users[msg.sender].deposits.length == 0){
            no_of_users = no_of_users+1;
            user.wallet = payable(msg.sender);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.total_withdrawn = 0;
            user.referral_reward = 0;
            user.users_update = (no_of_users)/1000;
	        user.contract_balance_update = (address(this).balance)/bonus_bal_at;
	        user.total_invested_by_user = msg.value;
            user.plan = 2;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
    			user.referrer = referrer;
            }
    		else{
    		    user.referrer = address(0);
    		}
    		user.lastaction = block.timestamp;
        }
        //existing users
        else{
            require(user.plan==2);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
	        user.total_invested_by_user = user.total_invested_by_user+msg.value;
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.lastaction = block.timestamp;
        }
        //paying rewards
        address upline = user.referrer;
    	for (uint256 i = 0; i < 4; i++) {
    		if (upline != address(0)) {
    		    if(i==0){
    		        users[upline].no_of_referals = users[upline].no_of_referals+1;
    		    }
    		    uint256 amount = msg.value*(referral_rewards[i])/(100);
				users[upline].referral_reward = users[upline].referral_reward+(amount);
				upline = users[upline].referrer;
    		}
    		else break;
    	}
    	return true;
	}

	//function for plan 3 users
	function user_deposit_plan_3(address referrer) public payable returns(bool){
	    require(msg.value>=minimum_deposit_3);
        user_stuct storage user = users[msg.sender];
        total_invested = total_invested+msg.value;
        // first time users
        if(users[msg.sender].deposits.length == 0){
            no_of_users = no_of_users+1;
            user.wallet = payable(msg.sender);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.total_withdrawn = 0;
            user.referral_reward = 0;
            user.users_update = (no_of_users)/1000;
            user.total_invested_by_user = msg.value;
	        user.contract_balance_update = (address(this).balance)/bonus_bal_at;
            user.plan = 3;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
    			user.referrer = referrer;
            }
    		else{
    		    user.referrer = address(0);
    		}
    		user.lastaction = block.timestamp;
        }
        //existing users
        else{
            require(user.plan==3);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
	        user.total_invested_by_user = user.total_invested_by_user+msg.value;
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.lastaction = block.timestamp;
        }
        //paying rewards
        address upline = user.referrer;
    	for (uint256 i = 0; i < 4; i++) {
    		if (upline != address(0)) {
    		    if(i==0){
    		        users[upline].no_of_referals=users[upline].no_of_referals+1;
    		    }
    		    uint256 amount = msg.value*(referral_rewards[i])/(100);
				users[upline].referral_reward = users[upline].referral_reward+(amount);
				upline = users[upline].referrer;
    		}
    		else break;
    	}
    	return true;
	}

	//function for plan 4 users
	function user_deposit_plan_4(address referrer) public payable returns(bool){
	    require(msg.value>=minimum_deposit_4);
        user_stuct storage user = users[msg.sender];
        total_invested = total_invested+msg.value;
        // first time users
        if(users[msg.sender].deposits.length == 0){
            no_of_users = no_of_users+1;
            user.wallet = payable(msg.sender);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.total_withdrawn = 0;
            user.referral_reward = 0;
            user.users_update = (no_of_users)/1000;
            user.total_invested_by_user = msg.value;
	        user.contract_balance_update = (address(this).balance)/bonus_bal_at;
            user.plan = 4;
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
    			user.referrer = referrer;
            }
    		else{
    		    user.referrer = address(0);
    		}
    		user.lastaction = block.timestamp;
        }
        //existing users
        else{
            require(user.plan==4);
	        dev_fee = dev_fee+((msg.value/(1000))*(developer_fee));
	        team_fee = team_fee+((msg.value/(1000))*(marketing_fee));
	        user.total_invested_by_user = user.total_invested_by_user+msg.value;
            user.deposits.push(deposit(msg.value, block.timestamp, 0, block.timestamp));
            user.lastaction = block.timestamp;
        }
        //paying rewards
        address upline = user.referrer;
    	for (uint256 i = 0; i < 4; i++) {
    		if (upline != address(0)) {
    		    if(i==0){
    		        users[upline].no_of_referals=users[upline].no_of_referals+1;
    		    }
    		    uint256 amount = msg.value*(referral_rewards[i])/(100);
				users[upline].referral_reward = users[upline].referral_reward+(amount);
				upline = users[upline].referrer;
    		}
    		else break;
    	}
    	return true;
	}


	//function to get user data
	function get_user_data(address _user_wallet) public view returns(uint256 _plan, address _user_referrer, uint256 _current_referal_reward, uint256 _no_of_referals, uint256 _total_withdrawn_amount, uint256 _no_of_deposits, uint256 _total_deposit_amount, uint256 _last_action, uint256 _contract_balance_update,  uint256 _users_update){
	    user_stuct storage user = users[_user_wallet];
	    _plan = user.plan;
	    _user_referrer = user.referrer;
	    _no_of_referals=user.no_of_referals;
	    _current_referal_reward = user.referral_reward;
	    _total_withdrawn_amount = user.total_withdrawn;
	    _no_of_deposits=user.deposits.length;
	    _total_deposit_amount=0;
	    _last_action=user.lastaction;
	    _contract_balance_update=user.contract_balance_update;
	    _users_update=user.users_update;
	    for(uint256 i=0; i<_no_of_deposits; i++){
	        _total_deposit_amount=_total_deposit_amount+user.deposits[i].amount;
	    }
	}
	
	//calculate ROI 
	function calculate_roi(uint256 _plan, uint256 _timestamp) public view returns(uint256 ROI){
	    if (_plan==1){
	        ROI=20;
	    }
	    else if(_plan==2){
	        uint256 _delta = (block.timestamp - _timestamp)/(24*60*60);
	        if (_delta<1){
	            ROI=20;
	        }
	        else{
	            if (_delta<10){
	                ROI = 20+(_delta);
	            }
	            else{
	                ROI=30;
	            }
	        }
	    }
	    else if(_plan==3){
	        uint256 _delta = (block.timestamp - _timestamp)/(24*60*60);
	        if (_delta<1){
	            ROI=30;
	        }
	        else{
	            if (_delta<10){
	                ROI = 30+(_delta);
	            }
	            else{
	                ROI=40;
	            }
	        } 
	    }
	    else if(_plan==4){
	        uint256 _delta = (block.timestamp - _timestamp)/(24*60*60);
	        if (_delta<1){
	            ROI=40;
	        }
	        else{
	            if (_delta<10){
	                ROI = 40+(_delta);
	            }
	            else{
	                ROI=50;
	            }
	        } 
	    }
	}
	
	//function to calculate bonus
	function bonus_calc(uint256 _user_no, uint256 _con_balance) public view returns(uint256 _bonus){
	    uint256 _user_bonus= (no_of_users/1000)-_user_no;
	    uint256 _con_bal_bonus=(address(this).balance/bonus_bal_at)-_con_balance;
	    _bonus=_user_bonus+(_con_bal_bonus*2);
	}
	
	// returns current earnings
	function earnings(address _address) view public returns(uint256 total){
        user_stuct memory user = users[_address];
	    uint256 noofdeposits = user.deposits.length;
	    uint256 withdrawable_balance = 0;
	    uint256 _plan = user.plan;
	    total=0;
	    if (_plan==1){
	        for(uint256 i=0; i<noofdeposits; i++){
                withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	            total=total+withdrawable_balance;
	        }
	    if (user.no_of_referals>=3){
	        total=total+user.referral_reward;
	    }
	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
	    return total;
	    }
	    else if (_plan==2){
	        for(uint256 i=0; i<noofdeposits; i++){
                withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	            if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*32))/10){
                    withdrawable_balance=(((user.deposits[i].amount*32))/10)-user.deposits[i].withdrawn;
	            }
	            total=total+withdrawable_balance;
	        }
	    if (user.no_of_referals>=3){
	        total=total+user.referral_reward;
	    }
	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
	    return total;
	    }
	    else if (_plan==3){
	        for(uint256 i=0; i<noofdeposits; i++){
                withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	            if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*30))/10){
                    withdrawable_balance=(((user.deposits[i].amount*30))/10)-user.deposits[i].withdrawn;
	            }
	            total=total+withdrawable_balance;
	        }
	    if (user.no_of_referals>=3){
	        total=total+user.referral_reward;
	    }
	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
	    return total;
	    }
	    else if (_plan==4){
	        for(uint256 i=0; i<noofdeposits; i++){
                withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	            if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*28))/10){
                    withdrawable_balance=(((user.deposits[i].amount*28))/10)-user.deposits[i].withdrawn;
	            }
	            total=total+withdrawable_balance;
	        }
	    if (user.no_of_referals>=3){
	        total=total+user.referral_reward;
	    }
	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
	    return total;
	    }
	}
	
	//function to check the avilability of withdraw
	function check_withdraw_status(address _address) public view returns (bool){
	    user_stuct memory user = users[_address];
	    if ((user.lastaction+86400)<block.timestamp){
	        return true;
	    }
	    else{
	        return false;
	    }
	}
	
	function withdraw() public payable returns(bool status){
	    user_stuct storage user = users[msg.sender];
        if (check_withdraw_status(msg.sender)){
            uint256 total = 0;
    	    uint256 noofdeposits = user.deposits.length;
    	    uint256 withdrawable_balance = 0;
    	    uint256 _plan = user.plan;
    	    if (_plan==1){
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance = (user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
    	            total = total+withdrawable_balance;
    	            user.deposits[i].lastaction = block.timestamp;
    	            user.deposits[i].withdrawn = user.deposits[i].withdrawn+withdrawable_balance;
        	        }
        	    if (user.no_of_referals>=3){
        	        total=total+user.referral_reward;
        	        user.referral_reward=0;
        	    }
        	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
        	    uint256 effective_balance = address(this).balance - (dev_fee+team_fee);
    			if (total>effective_balance){
    			    total=effective_balance;
    			}
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    payable(msg.sender).transfer(total);
        	    return true;
    	    }
    	    else if (_plan==2){
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	                if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*30))/10){
                        withdrawable_balance=(((user.deposits[i].amount*30))/10)-user.deposits[i].withdrawn;
	                }
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
        	    if (user.no_of_referals>=3){
        	        total=total+user.referral_reward;
        	        user.referral_reward=0;
        	    }
        	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
        	    uint256 effective_balance = address(this).balance - (dev_fee+team_fee);
        	    if (total>effective_balance){
        		     total=effective_balance;
        		}
            	user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
            	user.total_withdrawn=user.total_withdrawn+total;
            	user.lastaction=block.timestamp;
            	payable(msg.sender).transfer(total);
            	return true;
    	    }
    	    else if (_plan==3){
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	                if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*30))/10){
                        withdrawable_balance=(((user.deposits[i].amount*30))/10)-user.deposits[i].withdrawn;
	                }
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
        	    if (user.no_of_referals>=3){
        	        total=total+user.referral_reward;
        	        user.referral_reward=0;
        	    }
        	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
    	        uint256 effective_balance = address(this).balance - (dev_fee+team_fee);
        	    if (total>effective_balance){
        		     total=effective_balance;
        		}
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    payable(msg.sender).transfer(total);
        	    return true;
    	    }
    	    else if (_plan==4){
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	                if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*28))/10){
                        withdrawable_balance=(((user.deposits[i].amount*28))/10)-user.deposits[i].withdrawn;
	                }
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
        	    if (user.no_of_referals>=3){
        	        total=total+user.referral_reward;
        	        user.referral_reward=0;
        	    }
        	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
    	        uint256 effective_balance = address(this).balance - (dev_fee+team_fee);
        	    if (total>effective_balance){
        		     total=effective_balance;
        		}
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    payable(msg.sender).transfer(total);
        	    return true;
    	    }
        }
        else{
            return false;
        }
	}
	
	//function to reinvest
	function re_invest() public returns(bool status){
	    user_stuct storage user = users[msg.sender];
        if (check_withdraw_status(msg.sender)){
            uint256 total = 0;
    	    uint256 noofdeposits = user.deposits.length;
    	    uint256 withdrawable_balance = 0;
    	    uint256 _plan = user.plan;
    	    if (_plan==1){
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
        	    }
        	    total=total+user.referral_reward;
        	    total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
                dev_fee = dev_fee+((total/(1000))*(developer_fee));
	            team_fee = team_fee+((total/(1000))*(marketing_fee));
	            user.total_invested_by_user=user.total_invested_by_user+total;
        	    user.deposits.push(deposit(total, block.timestamp, 0, block.timestamp));
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    user.referral_reward=0;
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    return true;
    	    }
    	    else if (_plan==2){
                total=0;
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
    	            if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*32))/10){
                        withdrawable_balance=(((user.deposits[i].amount*32))/10)-user.deposits[i].withdrawn;
    	            }
    	            total = total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
    	        total=total+user.referral_reward;
    	        total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
                dev_fee = dev_fee+((total/(1000))*(developer_fee));
	            team_fee = team_fee+((total/(1000))*(marketing_fee));
	            user.total_invested_by_user = user.total_invested_by_user+total;
        	    user.deposits.push(deposit(total, block.timestamp, 0, block.timestamp));
        	    user.total_withdrawn = user.total_withdrawn+total;
        	    user.lastaction = block.timestamp;
        	    user.referral_reward = 0;
        	    user.users_update = (no_of_users)/1000;
	            user.contract_balance_update = (address(this).balance)/bonus_bal_at;
        	    return true;
    	    }
    	    else if (_plan==3){
                total=0;
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	                if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*30))/10){
                        withdrawable_balance=(((user.deposits[i].amount*30))/10)-user.deposits[i].withdrawn;
	                }
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
    	        total=total+user.referral_reward;
    	        total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
                dev_fee = dev_fee+((total/(1000))*(developer_fee));
	            team_fee = team_fee+((total/(1000))*(marketing_fee));
	            user.total_invested_by_user=user.total_invested_by_user+total;
        	    user.deposits.push(deposit(total, block.timestamp, 0, block.timestamp));
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    user.referral_reward=0;
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    return true;
    	    }
        else if (_plan==4){
                total=0;
    	        for(uint256 i=0; i<noofdeposits; i++){
                    withdrawable_balance=(user.deposits[i].amount*calculate_roi(_plan,user.deposits[i].lastaction))*(block.timestamp-user.deposits[i].lastaction)/(86400*1000);
	                if((withdrawable_balance+user.deposits[i].withdrawn) > ((user.deposits[i].amount*28))/10){
                        withdrawable_balance=(((user.deposits[i].amount*28))/10)-user.deposits[i].withdrawn;
	                }
    	            total=total+withdrawable_balance;
    	            user.deposits[i].lastaction=block.timestamp;
    	            user.deposits[i].withdrawn=user.deposits[i].withdrawn+withdrawable_balance;
    	        }
    	        total=total+user.referral_reward;
    	        total=total+(user.total_invested_by_user*bonus_calc(user.users_update,user.contract_balance_update))/(100);
                dev_fee = dev_fee+((total/(1000))*(developer_fee));
	            team_fee = team_fee+((total/(1000))*(marketing_fee));
	            user.total_invested_by_user=user.total_invested_by_user+total;
        	    user.deposits.push(deposit(total, block.timestamp, 0, block.timestamp));
        	    user.total_withdrawn=user.total_withdrawn+total;
        	    user.lastaction=block.timestamp;
        	    user.referral_reward=0;
        	    user.users_update=(no_of_users)/1000;
	            user.contract_balance_update=(address(this).balance)/bonus_bal_at;
        	    return true;
    	    }
        }
        else{
            return false;
        }
	}
	
	//get deposit details
	function get_deposit(address _user_wallet, uint256 _slno) public view returns (uint256 _no_of_deposits, uint256 _amount, uint256 _start, uint256 _withdrawn, uint256 _lastaction){
	     user_stuct storage user = users[_user_wallet];
	     _no_of_deposits=user.deposits.length;
	     _amount=user.deposits[_slno].amount;
	     _start=user.deposits[_slno].start;
	     _withdrawn=user.deposits[_slno].withdrawn;
	     _lastaction=user.deposits[_slno].lastaction;
	}
	
	//connect team account
	function set_team() public returns(bool){
	    if(team==address(0)){
	        team=payable(msg.sender);
	        return true;
	    }
	    else{
	        return false;
	    }
	}
	
	//connect team2 account
	function set_team_2() public returns(bool){
	    if(team_2==address(0)){
	        team_2=payable(msg.sender);
	        return true;
	    }
	    else{
	        return false;
	    }
	}
	
    //show fee
	function pay_fee() view public returns(uint256){
	    if(msg.sender==dev || msg.sender==team){
	        if(msg.sender==dev){
	            return dev_fee;
	        }
	        else{
	            return team_fee;
	        }
	    }
	    else{
	        return 0;
	    }
	}
	
	//pay developer fee
    function devfeepay() public payable returns(bool){
        require(msg.sender==dev);
        dev.transfer(dev_fee);
        dev_fee=0;
        fee_avilability=1;
        return true;
    }
    
    //pay team fee
    function ownfeepay() public payable returns(bool){
        require(msg.sender==team && fee_avilability==1);
        uint256 team_1_fee=(team_fee*75)/100;
        uint256 team_2_fee=(team_fee*25)/100;
        team.transfer(team_1_fee);
        team_2.transfer(team_2_fee);
        team_fee=0;
        return true;
    }
    
    //get contract details
    function get_contract_details() public view returns(uint256 _balance, uint256 _no_of_users, uint256 _total_deposit_amount){
        _balance=address(this).balance;
        _no_of_users=no_of_users;
        _total_deposit_amount=total_invested;
    }
}