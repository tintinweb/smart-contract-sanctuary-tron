//SourceUnit: CyberChain2.sol

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

interface ICyberChain {
    enum Overflow {
        DOWN,
        DIRECT,
        UP,
        OUTRUN
    }

    event Register(address indexed addr, address indexed upline, uint256 id, uint40 time);
    event BuyLevel(address indexed addr, uint8 level, uint40 time);
    event SetFirstLine(address indexed addr, address indexed upline, uint8 level, Overflow overflow, uint40 time);
    event SetSecondLine(address indexed addr, address indexed upline, uint8 level, Overflow overflow, uint40 time);
    event Reinvest(address indexed addr, uint8 level, uint40 time);
    event Profit(address indexed addr, uint256 amount, uint40 time);
    event Lost(address indexed addr, uint256 amount, uint40 time);

    function register(address payable _upline) payable external;
    function register(uint256 _upline_id) payable external;
    function upgrade() payable external returns(uint8 level);

    function contractInfo() view external returns(uint256 _last_id, uint256 _turnover);
    function getUserById(uint256 _id) view external returns(address addr, address upline);
    function userInfo(address _addr) view external returns(uint256 id, address upline, uint8 level, uint256 profit, uint256 lost);
    function userStructure(address _addr) view external returns(uint256[12] memory reinvests, uint256[12][4] memory referrals, uint256[12][3] memory referrals_line1, uint8[12][3] memory overflow_line1, uint256[12][8] memory referrals_line2, uint8[12][8] memory overflow_line2);
    function userLevelStructure(address _addr, uint8 _level) view external returns(bool active, address upline, uint256 reinvests, uint256[4] memory referrals, uint256[3] memory referrals_line1, uint8[3] memory overflow_line1, uint256[8] memory referrals_line2, uint8[8] memory overflow_line2);
}

contract CyberChain is ICyberChain {
    struct Level {
        bool active;
        address payable upline;
        address payable[] referrals_line1;
        Overflow[] overflow_line1;
        address payable[] referrals_line2;
        Overflow[] overflow_line2;
        uint256 reinvest;
        mapping(uint8 => uint256) referrals;
    }

    struct User {
        uint256 id;
        address payable upline;
        uint256 profit;
        uint256 lost;
        mapping(uint8 => Level) levels;
    }
    
    uint8 public constant MAX_LEVEL = 12;

    address payable public root;
    uint256 public last_id;
    uint256 public turnover;

    uint256[] public levels;
    mapping(address => User) public users;
    mapping(uint256 => address payable) public users_ids;
    
    address payable public fee1;
    address payable public fee2;

    constructor() public {
        root = 0x8d1e0128f12Ef69B9391522Bf39F87a10e5877de;
        fee1 = 0xBe90431790aEe49BbBEeceA0149B1e6Cb06bD7D3;
        fee2 = 0xd02243701dA5e8961Aa786f7B401d80294bEa4d2;

        _addUser(root, address(0));

        for(uint8 i = 0; i < MAX_LEVEL; i++) {
            levels.push(i > 0 ? (levels[i - 1] * (i > 6 ? 3 : 2)) : 1e8);

            users[root].levels[i].active = true;
            
            emit BuyLevel(root, i, uint40(block.timestamp));
        }
    }

    function() payable external {
        _register(msg.sender, _bytesToAddress(msg.data), msg.value);
    }

    function _addUser(address payable _user, address payable _upline) private {
        users[_user].id = ++last_id;
        users[_user].upline = _upline;
        users_ids[last_id] = _user;

        emit Register(_user, _upline, last_id, uint40(block.timestamp));
    }

    function _send(address payable _addr, uint256 _value) private {
        if(_addr == address(0) || !_addr.send(_value)) {
            root.transfer(_value);
        }
        else {
            users[_addr].profit += _value;
            emit Profit(_addr, _value, uint40(block.timestamp));
        }
    }

    function _sendComm() private {
        fee1.transfer(address(this).balance / 2);
        fee2.transfer(address(this).balance);
    }

    function _setLevelUpline(address payable _user, address payable _upline, uint8 _level, bool _second, Overflow _overflow) private {
        users[_upline].levels[_level].referrals[uint8(_overflow)]++;

        if(_second) {
            users[_upline].levels[_level].referrals_line2.push(_user);
            users[_upline].levels[_level].overflow_line2.push(_overflow);
            
            emit SetSecondLine(_user, _upline, _level, _overflow, uint40(block.timestamp));
        }
        else {
            users[_user].levels[_level].upline = _upline;

            users[_upline].levels[_level].referrals_line1.push(_user);
            users[_upline].levels[_level].overflow_line1.push(_overflow);
            
            emit SetFirstLine(_user, _upline, _level, _overflow, uint40(block.timestamp));
        }
    }

    function _reinvest(address payable _user, uint8 _level) private {
        users[_user].levels[_level].referrals_line1 = new address payable[](0);
        users[_user].levels[_level].overflow_line1 = new Overflow[](0);
        users[_user].levels[_level].referrals_line2 = new address payable[](0);
        users[_user].levels[_level].overflow_line2 = new Overflow[](0);
        users[_user].levels[_level].reinvest++;

        emit Reinvest(_user, _level, uint40(block.timestamp));

        if(_user != root) _buyLevel(_user, _level, true);
    }

    function _buyLevel(address payable _user, uint8 _level, bool _reinv) private {
        if(!_reinv) {
            users[_user].levels[_level].active = true;

            emit BuyLevel(_user, _level, uint40(block.timestamp));
        }

        address payable upline = _findUplineHasLevel(users[_user].upline, _level);
        bool overflow = users[_user].upline != upline;

        if(overflow) {
            users[users[_user].upline].lost += levels[_level];

            emit Lost(users[_user].upline, levels[_level], uint40(block.timestamp));
        }

        if(users[upline].levels[_level].referrals_line1.length < 3) {
            _setLevelUpline(_user, upline, _level, false, overflow ? Overflow.OUTRUN : Overflow.DIRECT);

            address payable sup_upline = users[upline].levels[_level].upline;

            if(sup_upline != address(0)) {
                if(!_reinv) {
                    _send(upline, levels[_level] / 2);

                    if(users[sup_upline].levels[_level].referrals_line2.length > 7) _send(_findUplineHasLevel(users[users[_user].upline].upline, _level), levels[_level] / 2);
                    else if(users[sup_upline].levels[_level].referrals_line2.length > 6) _send(_findUplineHasLevel(users[_user].upline, _level), levels[_level] / 2);
                    else _send(sup_upline, levels[_level] / 2);
                }

                if(users[sup_upline].levels[_level].referrals_line2.length < 8) {
                    _setLevelUpline(_user, sup_upline, _level, true, overflow ? Overflow.OUTRUN : Overflow.DOWN);
                }
                else _reinvest(sup_upline, _level);
            }
            else if(!_reinv) _send(upline, levels[_level]);
        }
        else {
            address payable sub_upline = _findFreeReferrer(upline, _level);

            _setLevelUpline(_user, sub_upline, _level, false, overflow ? Overflow.OUTRUN : Overflow.UP);

            if(!_reinv) {
                _send(sub_upline, levels[_level] / 2);
                
                if(users[upline].levels[_level].referrals_line2.length > 7) _send(_findUplineHasLevel(_findUplineOffset(_user, 3), _level), levels[_level] / 2);
                else if(users[upline].levels[_level].referrals_line2.length > 6) _send(_findUplineHasLevel(_findUplineOffset(_user, 2), _level), levels[_level] / 2);
                else _send(upline, levels[_level] / 2);
            }

            if(users[upline].levels[_level].referrals_line2.length < 8) {
                _setLevelUpline(_user, upline, _level, true, overflow ? Overflow.OUTRUN : Overflow.DIRECT);
            }
            else _reinvest(upline, _level);
        }
    }

    function _register(address payable _user, address payable _upline, uint256 _value) private {
        require(_value == this.levelPriceWithComm(0), "Invalid amount");
        require(users[_user].upline == address(0) && _user != root, "User already exists");
        require(users[_upline].upline != address(0) || _upline == root, "Upline not found");

        _addUser(_user, _upline);
        _buyLevel(_user, 0, false);
        _sendComm();

        turnover += levels[0];
    }

    function register(address payable _upline) payable external {
        _register(msg.sender, _upline, msg.value);
    }

    function register(uint256 _upline_id) payable external {
        _register(msg.sender, users_ids[_upline_id], msg.value);
    }

    function upgrade() payable external returns(uint8 level) {
        require(users[msg.sender].upline != address(0), "User not register");

        for(uint8 i = 1; i < MAX_LEVEL; i++) {
            if(!users[msg.sender].levels[i].active) {
                level = i;
                break;
            }
        }

        require(level > 0, "All levels active");
        require(msg.value == this.levelPriceWithComm(level), "Invalid amount");

        _buyLevel(msg.sender, level, false);
        _sendComm();

        turnover += levels[level];
    }

    function _bytesToAddress(bytes memory _data) private pure returns(address payable addr) {
        assembly {
            addr := mload(add(_data, 20))
        }
    }

    function _findUplineHasLevel(address payable _user, uint8 _level) private view returns(address payable) {
        if(_user == root || (users[_user].levels[_level].active && (users[_user].levels[_level].reinvest == 0 || users[_user].levels[_level + 1].active || _level + 1 == MAX_LEVEL))) return _user;

        return _findUplineHasLevel(users[_user].upline, _level);
    }

    function _findUplineOffset(address payable _user, uint8 _offset) private view returns(address payable) {
        if(_user == root || _offset == 0) return _user;

        return _findUplineOffset(users[_user].upline, _offset - 1);
    }

    function _findFreeReferrer(address payable _user, uint8 _level) private view returns(address payable) {
        for(uint8 i = 0; i < 3; i++) {
            address payable ref = users[_user].levels[_level].referrals_line1[i];

            if(users[ref].levels[_level].referrals_line1.length < 3) {
                return ref;
            }
        }
    }

    function levelPriceWithComm(uint8 _level) view external returns(uint256) {
        return levels[_level] + (levels[_level] / 100 * 4);
    }

    /*
        Only external call
    */
    function contractInfo() view external returns(uint256 _last_id, uint256 _turnover) {
        return (last_id, turnover);
    }

    function getUserById(uint256 _id) view external returns(address addr, address upline) {
        return (users_ids[_id], users[users_ids[_id]].upline);
    }

    function userInfo(address _addr) view external returns(uint256 id, address upline, uint8 level, uint256 profit, uint256 lost) {
        for(uint8 l = 0; l < MAX_LEVEL; l++) {
            if(!users[_addr].levels[l].active) break;

            level = l;
        }

        return (users[_addr].id, users[_addr].upline, level, users[_addr].profit, users[_addr].lost);
    }

    function userStructure(address _addr) view external returns(uint256[12] memory reinvests, uint256[12][4] memory referrals, uint256[12][3] memory referrals_line1, uint8[12][3] memory overflow_line1, uint256[12][8] memory referrals_line2, uint8[12][8] memory overflow_line2) {
        for(uint8 l = 0; l < MAX_LEVEL; l++) {
            if(!users[_addr].levels[l].active) break;

            reinvests[l] = users[_addr].levels[l].reinvest;
            
            for(uint8 i = 0; i < 4; i++) {
                referrals[i][l] = users[_addr].levels[l].referrals[i];
            }

            for(uint8 i = 0; i < 3; i++) {
                if(i >= users[_addr].levels[l].referrals_line1.length) break;
                
                referrals_line1[i][l] = users[users[_addr].levels[l].referrals_line1[i]].id;
                overflow_line1[i][l] = uint8(users[_addr].levels[l].overflow_line1[i]);
            }

            for(uint8 i = 0; i < 8; i++) {
                if(i >= users[_addr].levels[l].referrals_line2.length) break;
                
                referrals_line2[i][l] = users[users[_addr].levels[l].referrals_line2[i]].id;
                overflow_line2[i][l] = uint8(users[_addr].levels[l].overflow_line2[i]);
            }
        }
    }

    function userLevelStructure(address _addr, uint8 _level) view external returns(bool active, address upline, uint256 reinvests, uint256[4] memory referrals, uint256[3] memory referrals_line1, uint8[3] memory overflow_line1, uint256[8] memory referrals_line2, uint8[8] memory overflow_line2) {
        active = users[_addr].levels[_level].active;
        upline = users[_addr].levels[_level].upline;
        reinvests = users[_addr].levels[_level].reinvest;
        
        for(uint8 i = 0; i < 4; i++) {
            referrals[i] = users[_addr].levels[_level].referrals[i];
        }

        for(uint8 i = 0; i < 3; i++) {
            if(i >= users[_addr].levels[_level].referrals_line1.length) break;
            
            referrals_line1[i] = users[users[_addr].levels[_level].referrals_line1[i]].id;
            overflow_line1[i] = uint8(users[_addr].levels[_level].overflow_line1[i]);
        }

        for(uint8 i = 0; i < 8; i++) {
            if(i >= users[_addr].levels[_level].referrals_line2.length) break;
            
            referrals_line2[i] = users[users[_addr].levels[_level].referrals_line2[i]].id;
            overflow_line2[i] = uint8(users[_addr].levels[_level].overflow_line2[i]);
        }
    }
}

contract Sync is CyberChain {
    CyberChain cyberchain;

    address public sync_owner;
    uint256 public sync_id;
    
    modifier onlySync() {
        require(msg.sender == sync_owner, "Sync already close");
        _;
    }

    constructor() public {
        cyberchain = CyberChain(0xCf5A68E6ebB3b2AC1B1111d1bE14Be234afa45e9);
        sync_owner = msg.sender;
    }

    function _syncUserStructure(address _addr, uint8 _level) private {
        (uint256[12] memory reinvests, uint256[12][4] memory referrals, uint256[12][3] memory referrals_line1, uint8[12][3] memory overflow_line1, uint256[12][8] memory referrals_line2, uint8[12][8] memory overflow_line2) = cyberchain.userStructure(_addr);

        for(uint8 l = 0; l <= _level; l++) {
            users[_addr].levels[l].active = true;
            users[_addr].levels[l].reinvest = reinvests[l];

            for(uint8 i = 0; i < 3; i++) {
                users[_addr].levels[l].referrals_line1[i] = users_ids[referrals_line1[i][l]];
                users[_addr].levels[l].overflow_line1[i] = Overflow(overflow_line1[i][l]);
            }

            for(uint8 i = 0; i < 8; i++) {
                users[_addr].levels[l].referrals_line2[i] = users_ids[referrals_line2[i][l]];
                users[_addr].levels[l].overflow_line2[i] = Overflow(overflow_line2[i][l]);
            }

            for(uint8 i = 0; i < 4; i++) {
                users[_addr].levels[l].referrals[i] = referrals[i][l];
            }
        }
    }

    function _syncUser(address payable _addr) private {
        (uint256 id, address upline, uint8 level, uint256 profit, uint256 lost) = cyberchain.userInfo(_addr);
        
        require(id > 0, "User not found");

        users[_addr] = User({
            id: id,
            upline: address(uint160(upline)),
            profit: profit,
            lost: lost
        });
        users_ids[id] = _addr;
        
        _syncUserStructure(_addr, level);
    }

    function sync(uint256 _limit) external onlySync {
        require(_limit > 0, "Zero limit");

        last_id = cyberchain.last_id();

        for(uint256 i = sync_id + 1; i <= last_id; i++) {
            if(--_limit == 0) break;

            (address addr,) = cyberchain.getUserById(i);

            _syncUser(address(uint160(addr)));
            sync_id = i;
        }
    }

    function syncById(uint256 _id) external onlySync {
        (address addr,) = cyberchain.getUserById(_id);

        _syncUser(address(uint160(addr)));
    }

    function syncClose() external onlySync {
        turnover = cyberchain.turnover();
        sync_owner = address(0);
    }
}