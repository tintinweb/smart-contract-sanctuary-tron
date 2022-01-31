//SourceUnit: tron24.sol

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;



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


contract Ownable   {
    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {
        return _owner;
    }

    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}

contract TronSon  is Ownable{
    
    using SafeMath for uint256;
        

        constructor()  
    {
        pools[1]=500000;   // 0.5%
        pools[2]=750000;   // 0.75%
        pools[3]=1000000;  // 1%
        pools[4]=1500000;  // 1.5%
        pools[5]=3000000;  // 3%
        pools[6]=5000000;  // 5%

    }

        struct User 
    {
        address payable upline;
        uint256 referrals;
        uint256 TotalUserreferrals;
        uint256 deposit_time;
        uint256 total_deposits;
        uint256 Amount;
        uint256 Rewards;
        uint256 Level;
        uint256 entry_time;
        uint256 index;
        uint256 LevelTime;
        uint256 totalReward;
    }  

        struct user 
    {
        uint256 rewardlevel;

    }


        uint256 public total_users;
        uint256 public total_Withdrawn;
        uint256 public TotalStake;
        uint256 public TimePerHour = 2 hours;
        uint256 public TotalAmount;
        uint256 public TenPercentageAmount ;
        uint256 public RemainingAmount ;
        bool public StartSkaking; 
        bool public poolStatus;  

    mapping (uint256 => uint256 ) public pools;
    mapping (uint256 => uint256 ) public poolAmount;
    mapping(address => User) public users;
    mapping(address => user) public users1;
    mapping(uint256 => uint256) public poolTotalAmount;
     
    address [] public Holders;






         function _setUpline(address _addr, address payable _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != _owner && (users[_upline].deposit_time > 0 || _upline == _owner))
        {
            users[_addr].upline = _upline;
            users[_upline].referrals++;
            total_users++;
        }
    }
      function _chakUpline( address _upline , address add) public view returns(bool result){
        if(users[add].upline == address(0) && _upline != add && add != _owner && (users[_upline].deposit_time > 0 || _upline == _owner)) {
            return true;  

        }
    }
    


    function Stake(address payable upline) public payable 

    {
        
        require(poolStatus   == true , "please start staking");
        require(msg.value % 100 trx == 0 , "Invalid amount");
        require(msg.value    > 0 , "Invalid amount");
        require(users[msg.sender].Amount  == 0 , "user already exists");
        require(StartSkaking   == true , "please start staking");

        _setUpline(msg.sender,upline);
        payable(users[msg.sender].upline).transfer(users[msg.sender].Amount*10/100);

        users[msg.sender].Amount = msg.value;
        users[msg.sender].deposit_time = block.timestamp;
        users[msg.sender].entry_time = block.timestamp;
        users[msg.sender].LevelTime = block.timestamp;
        
        users[msg.sender].total_deposits += msg.value;
        users[msg.sender].Level = 1;
        Holders.push(msg.sender);
        users[msg.sender].index = Holders.length-1;
        TotalStake +=msg.value;
        poolTotalAmount[1] = users[msg.sender].Amount;
    
    }

    function CalculateReward(address add) public view returns(uint256)
    {
        uint256 Reward;
        if(users[add].totalReward <= users[add].Amount*350/100){
        if(block.timestamp > users[add].deposit_time + TimePerHour )
        {
            Reward = (users[add].Amount.mul(pools[users[add].Level])).div(100);
        }
        }
        return Reward/1000000;
    }

       function withdrawReward() public
    {
      require(users[msg.sender].Rewards > 0 , "reward not found");
      require(poolStatus   == true , "please start staking");

        if(users1[msg.sender].rewardlevel == 1 && users[msg.sender].Rewards > 10000000)
        {
            users1[msg.sender].rewardlevel = 2;
            payable(msg.sender).transfer(10000000*85/100);
            users[msg.sender].Rewards = users[msg.sender].Rewards.sub(10000000);
            users[msg.sender].totalReward = 10000000;
            total_Withdrawn +=10000000;
        }
        else if(users1[msg.sender].rewardlevel == 2 && users[msg.sender].Rewards > 50000000)
    {
            users1[msg.sender].rewardlevel = 2;
            payable(msg.sender).transfer(50000000*85/100);
            users[msg.sender].Rewards = users[msg.sender].Rewards.sub(50000000);
            users[msg.sender].totalReward = 50000000;
            total_Withdrawn +=50000000;
    }
        else if(users1[msg.sender].rewardlevel == 3  && users[msg.sender].Rewards > 100000000)
    {
            payable(msg.sender).transfer(100000000*85/100);
            users1[msg.sender].rewardlevel = 4;
            users[msg.sender].Rewards = users[msg.sender].Rewards.sub(100000000);
            users[msg.sender].totalReward = 100000000;
            total_Withdrawn +=100000000;
            
    }
            else if(users1[msg.sender].rewardlevel == 5  && users[msg.sender].Rewards > 500000000)
    {
            payable(msg.sender).transfer(500000000*85/100);
            users[msg.sender].Rewards = users[msg.sender].Rewards.sub(500000000);
            users[msg.sender].totalReward = 500000000;
            total_Withdrawn +=500000000;
            
    }
           
    }


        function Claim() public
    {
        require(poolStatus   == true , "please start staking");
        require(block.timestamp > users[msg.sender].deposit_time + TimePerHour , "please wait");
        if(users[msg.sender].totalReward <= users[msg.sender].Amount*350/100)
        {
           if(block.timestamp > users[msg.sender].deposit_time + TimePerHour )
         {
            users[msg.sender].Rewards += ((users[msg.sender].Amount.mul(pools[users[msg.sender].Level])).div(100)).div(1E6);
            users[msg.sender].deposit_time = block.timestamp;
            users1[msg.sender].rewardlevel = 1;
         }
        }
        else
        {
         users[msg.sender].referrals = 0;
         users[msg.sender].deposit_time = 0;
         users[msg.sender].total_deposits = 0;
         users[msg.sender].Amount = 0;
         users[msg.sender].Level = 0;
         users[msg.sender].entry_time = 0;
         users[msg.sender].LevelTime =0;

        for (uint256 z; z < Holders.length; z++) 
          { 

           for(uint i = users[msg.sender].index; i <  Holders.length - 1; i++)
            {
              Holders[i] = Holders[i + 1];
            }
               Holders.pop();
          }
          users[msg.sender].index = 0;
        }




//...........................................Levels.....................................................................................
        if(users[msg.sender].Level == 1)
        {

        if(block.timestamp  < users[msg.sender].LevelTime + 200 hours  && users[msg.sender].referrals >= 25)
        {
            users[msg.sender].Level = 2;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[1] = poolTotalAmount[1] - users[msg.sender].Amount;
            poolTotalAmount[2] = poolTotalAmount[2] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 96 hours  && users[msg.sender].referrals >= 15)
        {
            users[msg.sender].Level = 2;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[1] = poolTotalAmount[1] - users[msg.sender].Amount;
            poolTotalAmount[2] = poolTotalAmount[2] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 48 hours  && users[msg.sender].referrals >= 5)
        {
            users[msg.sender].Level = 2;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[1] = poolTotalAmount[1] - users[msg.sender].Amount;
            poolTotalAmount[2] = poolTotalAmount[2] + users[msg.sender].Amount;
        }
        }
        else if(users[msg.sender].Level == 2)
        {
       if(block.timestamp  < users[msg.sender].LevelTime + 240 hours  && users[msg.sender].referrals >= 25)
        {
            users[msg.sender].Level = 3;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[2] = poolTotalAmount[2] - users[msg.sender].Amount;
            poolTotalAmount[3] = poolTotalAmount[3] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 120 hours  && users[msg.sender].referrals >= 15)
        {
            users[msg.sender].Level = 3;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[2] = poolTotalAmount[2] - users[msg.sender].Amount;
            poolTotalAmount[3] = poolTotalAmount[3] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 60 hours  && users[msg.sender].referrals >= 5)
        {
            users[msg.sender].Level = 3;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[2] = poolTotalAmount[2] - users[msg.sender].Amount;
            poolTotalAmount[3] = poolTotalAmount[3] + users[msg.sender].Amount;
        }            
        }
                else if(users[msg.sender].Level == 3)
        {
       if(block.timestamp  < users[msg.sender].LevelTime + 288 hours  && users[msg.sender].referrals >= 25)
        {
            users[msg.sender].Level = 4;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[3] = poolTotalAmount[3] - users[msg.sender].Amount;
            poolTotalAmount[4] = poolTotalAmount[4] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 144 hours  && users[msg.sender].referrals >= 15)
        {
            users[msg.sender].Level = 4;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[3] = poolTotalAmount[3] - users[msg.sender].Amount;
            poolTotalAmount[4] = poolTotalAmount[4] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 72 hours  && users[msg.sender].referrals >= 5)
        {
            users[msg.sender].Level = 4;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[3] = poolTotalAmount[3] - users[msg.sender].Amount;
            poolTotalAmount[4] = poolTotalAmount[4] + users[msg.sender].Amount;
        }            
        }
          else if(users[msg.sender].Level == 4)
        {
       if(block.timestamp  < users[msg.sender].LevelTime + 96 hours  && users[msg.sender].referrals >= 15)
        {
            users[msg.sender].Level = 5;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[4] = poolTotalAmount[4] - users[msg.sender].Amount;
            poolTotalAmount[5] = poolTotalAmount[5] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 48 hours  && users[msg.sender].referrals >= 5)
        {
            users[msg.sender].Level = 5;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[4] = poolTotalAmount[4] - users[msg.sender].Amount;
            poolTotalAmount[5] = poolTotalAmount[5] + users[msg.sender].Amount;
        }            
        }
         else if(users[msg.sender].Level == 5)
        {
       if(block.timestamp  < users[msg.sender].LevelTime + 120 hours  && users[msg.sender].referrals >= 15)
        {
            users[msg.sender].Level = 6;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[5] = poolTotalAmount[5] - users[msg.sender].Amount;
            poolTotalAmount[6] = poolTotalAmount[6] + users[msg.sender].Amount;
        }
        else if(block.timestamp  < users[msg.sender].LevelTime + 60 hours  && users[msg.sender].referrals >= 5)
        {
            users[msg.sender].Level = 6;
            users[msg.sender].LevelTime = block.timestamp;
            users[msg.sender].TotalUserreferrals =users[msg.sender].referrals;
            users[msg.sender].referrals = 0;
            poolTotalAmount[5] = poolTotalAmount[5] - users[msg.sender].Amount;
            poolTotalAmount[6] = poolTotalAmount[6] + users[msg.sender].Amount;
        }            
        }
 }



    function ChangePoolAmount(uint256 min , uint256 mix ,uint256 minamount,uint256 mixamount) public onlyOwner
    {
        poolTotalAmount[min] = poolTotalAmount[min] - minamount;
            poolTotalAmount[mix] = poolTotalAmount[mix] + mixamount;
    }

 


         function emergencyWithdrawTRX(uint256 Amount) public onlyOwner 
    {
            payable(msg.sender).transfer(Amount);
    }


         function ChangePercentage(uint256 poolamount , uint256 Amount) public onlyOwner 
    {
        require(poolamount >= 1 && poolamount <= 6 , "invalid pool");
            pools[poolamount] = Amount;
    }    

             function Startstaking() public onlyOwner 
    {
             StartSkaking =  true;
    }    


             function Start() public onlyOwner 
    {
             poolStatus  =  true;
    }    
    

             function Stop() public onlyOwner 
    {
             poolStatus  =  false;
    }    
    
}