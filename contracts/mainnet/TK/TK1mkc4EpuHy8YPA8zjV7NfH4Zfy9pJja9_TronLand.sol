//SourceUnit: new.sol

pragma solidity ^0.4.25;

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

contract TronLand {

    using SafeMath for uint256;

    uint constant COIN_PRICE = 40000;
    uint constant TYPES_PLANTATION = 6;
    uint constant PERIOD = 60 minutes;
    uint constant MIN_DEPOSIT_ACTIVATING_REFERRAL = 1500e6;
    uint constant REFERRAL_PERCENT = 25;

    uint[TYPES_PLANTATION] prices = [3000, 11750, 44500, 155000, 470000, 950000];
    uint[TYPES_PLANTATION] profit = [4, 16, 62, 220, 680, 1400];

    uint public totalPlayers;
    uint public totalPlantation;
    uint public totalPayout;

    address owner;
    address manager1;
    address manager2;

    struct Player {
        uint coinsForBuy;
        uint coinsForSale;
        uint time;
        uint totalDeposited;
        address referral;
        uint[TYPES_PLANTATION] plantation;
    }

    mapping(address => Player) public players;

    constructor(address _owner, address _manager1, address _manager2) public {
        owner = _owner;
        manager1 = _manager1;
        manager2 = _manager2;
    }

    function deposit(address _referral) public payable {
        require(msg.value >= COIN_PRICE);

        uint coins = msg.value.div(COIN_PRICE);
        Player storage player = players[msg.sender];
        player.coinsForBuy = player.coinsForBuy.add(coins);
        player.totalDeposited = player.totalDeposited.add(msg.value);

        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
            
            if (_referral != address(0) && _referral != msg.sender &&
                players[_referral].totalDeposited > MIN_DEPOSIT_ACTIVATING_REFERRAL) {
                player.referral = _referral;
            }
        }
        
        if (player.referral != address(0)) {
            uint fee = coins.mul(REFERRAL_PERCENT).div(1000);
            players[player.referral].coinsForSale = players[player.referral].coinsForSale.add(fee);
        }
    }

    function buy(uint _type, uint _number) public {
        require(_type < TYPES_PLANTATION && _number > 0);
        collect(msg.sender);

        uint paymentCoins = prices[_type].mul(_number);
        Player storage player = players[msg.sender];

        require(paymentCoins <= player.coinsForBuy.add(player.coinsForSale));

        if (paymentCoins <= player.coinsForBuy) {
            player.coinsForBuy = player.coinsForBuy.sub(paymentCoins);
        } else {
            player.coinsForSale = player.coinsForSale.add(player.coinsForBuy).sub(paymentCoins);
            player.coinsForBuy = 0;
        }

        player.plantation[_type] = player.plantation[_type].add(_number);
        players[owner].coinsForSale = players[owner].coinsForSale.add( paymentCoins.mul(40).div(1000) );
        players[manager1].coinsForSale = players[manager1].coinsForSale.add( paymentCoins.mul(30).div(1000) );
        players[manager2].coinsForSale = players[manager2].coinsForSale.add( paymentCoins.mul(30).div(1000) );

        totalPlantation = totalPlantation.add(_number);
    }

    function withdraw(uint _coins) public {
        require(_coins > 0);
        collect(msg.sender);
        require(_coins <= players[msg.sender].coinsForSale);

        players[msg.sender].coinsForSale = players[msg.sender].coinsForSale.sub(_coins);
        transfer(msg.sender, _coins.mul(COIN_PRICE));
    }

    function collect(address _addr) internal {
        Player storage player = players[_addr];
        require(player.time > 0);

        uint hoursPassed = ( now.sub(player.time) ).div(PERIOD);
        if (hoursPassed > 0) {
            uint hourlyProfit;
            for (uint i = 0; i < TYPES_PLANTATION; i++) {
                hourlyProfit = hourlyProfit.add( player.plantation[i].mul(profit[i]) );
            }
            uint collectCoins = hoursPassed.mul(hourlyProfit);
            player.coinsForBuy = player.coinsForBuy.add( collectCoins.div(2) );
            player.coinsForSale = player.coinsForSale.add( collectCoins.div(2) );
            player.time = player.time.add( hoursPassed.mul(PERIOD) );
        }
    }

    function transfer(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
            uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);
                msg.sender.transfer(payout);
            }
        }
    }

    function plantationOf(address _addr) public view returns (uint[TYPES_PLANTATION]) {
        return players[_addr].plantation;
    }

}

contract TronLandBalance {

    uint constant TYPES_PLANTATION = 6;
    uint constant PERIOD = 60 minutes;
    uint[TYPES_PLANTATION] profit = [4, 16, 62, 220, 680, 1400];

    TronLand tronLand;

    constructor(address _addr) public {
        tronLand = TronLand(_addr);
    }

    function coinsOf(address _addr) public view returns(
        uint treasury,
        uint spare
    ) {
        uint hourlyProfit;
        uint time;
        uint[TYPES_PLANTATION] memory plantation = tronLand.plantationOf(_addr);

        for (uint i = 0; i < TYPES_PLANTATION; i++) {
            hourlyProfit += plantation[i] * profit[i];
        }

        (treasury, spare, time, , ) = tronLand.players(_addr);

        uint collectCoins = ((now - time) / PERIOD)  * hourlyProfit;
        treasury += collectCoins / 2;
        spare += collectCoins / 2;
    }

}