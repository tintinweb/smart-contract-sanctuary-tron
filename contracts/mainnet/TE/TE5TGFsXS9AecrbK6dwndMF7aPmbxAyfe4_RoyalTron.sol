//SourceUnit: RoyalTron.sol

pragma solidity ^0.4.25;// solhint-disable-line

contract RoyalTron {// solhint-disable-line
  using SafeMath for uint256;
  
  uint public totalPlayers;
  uint public totalPayout;
  uint public totalInvested;
  uint public minDepositSize = 50000000;
  uint public interestRateDivisor = 1000000000000;
  uint public devCommission = 10;
  uint public commissionDivisor = 100;
  uint public minuteRate = 1736110;
  uint public releaseTime = 1596197188;// 1595858400
  
  address owner;// solhint-disable-line
  address safeAddr;// solhint-disable-line
  
  struct Player {
    uint trxDeposit;
    uint time;
    uint interestProfit;
    uint affRewards;
    uint payoutSum;
    address affFrom;
    uint256 aff1sum;
    uint256 aff2sum;
    uint256 aff3sum;
    uint256 aff4sum;
    uint256 aff5sum;
  }
  
  mapping(address => Player) public players;
  
  constructor(address _safeAddr) public {
    owner = msg.sender;
    safeAddr = _safeAddr;
  }
  
  
  function register(address _addr, address _affAddr) private {
    
    Player storage player = players[_addr];
    
    player.affFrom = _affAddr;
    
    address _affAddr1 = _affAddr;
    address _affAddr2 = players[_affAddr1].affFrom;
    address _affAddr3 = players[_affAddr2].affFrom;
    address _affAddr4 = players[_affAddr3].affFrom;
    address _affAddr5 = players[_affAddr4].affFrom;
    
    players[_affAddr1].aff1sum = players[_affAddr1].aff1sum.add(1);
    players[_affAddr2].aff2sum = players[_affAddr2].aff2sum.add(1);
    players[_affAddr3].aff3sum = players[_affAddr3].aff3sum.add(1);
    players[_affAddr4].aff4sum = players[_affAddr4].aff4sum.add(1);
    players[_affAddr5].aff5sum = players[_affAddr5].aff5sum.add(1);
  }
  
  function () external payable {// solhint-disable-line
    
  }
  
  function deposit(address _affAddr) public payable {
    require(now >= releaseTime, "not time yet!");// solhint-disable-line
    collect(msg.sender);
    require(msg.value >= minDepositSize);
    
    
    uint depositAmount = msg.value;
    
    Player storage player = players[msg.sender];
    
    if (player.time == 0) {
      player.time = now;// solhint-disable-line
      totalPlayers++;
      if(_affAddr != address(0) && players[_affAddr].trxDeposit > 0) {
        register(msg.sender, _affAddr);
      }
      else {
        register(msg.sender, owner);
      }
    }
    player.trxDeposit = player.trxDeposit.add(depositAmount);
    
    distributeRef(msg.value, player.affFrom);
    
    totalInvested = totalInvested.add(depositAmount);
    uint devEarn = depositAmount.mul(devCommission).div(commissionDivisor);
    owner.transfer(devEarn);
    
    uint _safeFunds = depositAmount.mul(5).div(100);
    safeAddr.transfer(_safeFunds);
  }
  
  function withdraw() public {
    collect(msg.sender);
    require(players[msg.sender].interestProfit > 0);
    
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
    
    uint devEarn = depositAmount.mul(devCommission).div(commissionDivisor);
    owner.transfer(devEarn);
    
    uint _safeFunds = depositAmount.mul(5).div(100);
    safeAddr.transfer(_safeFunds);
  }
  
  
  function collect(address _addr) private {
    Player storage player = players[_addr];
    
    uint secPassed = now.sub(player.time);// solhint-disable-line
    if (secPassed > 0 && player.time > 0) {
      uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
      player.interestProfit = player.interestProfit.add(collectProfit);
      player.time = player.time.add(secPassed);
    }
  }
  
  function transferPayout(address _receiver, uint _amount) private {
    if (_amount > 0 && _receiver != address(0)) {
      uint contractBalance = address(this).balance;
      if (contractBalance > 0) {
        uint payout = _amount > contractBalance ? contractBalance : _amount;
        totalPayout = totalPayout.add(payout);
        
        Player storage player = players[_receiver];
        player.payoutSum = player.payoutSum.add(payout);
        player.interestProfit = player.interestProfit.sub(payout);
        
        msg.sender.transfer(payout);
      }
    }
  }
  
  function distributeRef(uint256 _trx, address _affFrom) private {
    
    uint256 _allaff = (_trx.mul(20)).div(100);
    
    address _affAddr1 = _affFrom;
    address _affAddr2 = players[_affAddr1].affFrom;
    address _affAddr3 = players[_affAddr2].affFrom;
    address _affAddr4 = players[_affAddr3].affFrom;
    address _affAddr5 = players[_affAddr4].affFrom;
    uint256 _affRewards = 0;
    
    if (_affAddr1 != address(0)) {
      _affRewards = (_trx.mul(10)).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[_affAddr1].affRewards = _affRewards.add(players[_affAddr1].affRewards);
      _affAddr1.transfer(_affRewards);
    }
    
    if (_affAddr2 != address(0)) {
      _affRewards = (_trx.mul(4)).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[_affAddr2].affRewards = _affRewards.add(players[_affAddr2].affRewards);
      _affAddr2.transfer(_affRewards);
    }
    
    if (_affAddr3 != address(0)) {
      _affRewards = (_trx.mul(3)).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[_affAddr3].affRewards = _affRewards.add(players[_affAddr3].affRewards);
      _affAddr3.transfer(_affRewards);
    }
    
    if (_affAddr4 != address(0)) {
      _affRewards = (_trx.mul(2)).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[_affAddr4].affRewards = _affRewards.add(players[_affAddr4].affRewards);
      _affAddr4.transfer(_affRewards);
    }
    
    if (_affAddr5 != address(0)) {
      _affRewards = (_trx.mul(1)).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[_affAddr5].affRewards = _affRewards.add(players[_affAddr5].affRewards);
      _affAddr5.transfer(_affRewards);
    }
    
    if(_allaff > 0 ) {
      owner.transfer(_allaff);
    }
  }
  
  function getProfit(address _addr) public view returns (uint) {
    address playerAddress= _addr;
    Player storage player = players[playerAddress];
    require(player.time > 0);
    
    uint secPassed = now.sub(player.time);// solhint-disable-line
    if (secPassed > 0) {
      uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
    }
    return collectProfit.add(player.interestProfit);
  }
}
library SafeMath {// solhint-disable-line
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