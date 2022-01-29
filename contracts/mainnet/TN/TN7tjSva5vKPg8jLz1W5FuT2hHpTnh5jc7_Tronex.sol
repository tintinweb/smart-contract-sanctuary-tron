//SourceUnit: data.sol

pragma solidity 0.5.9;

interface ITronForAll {
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
    event Profit(address indexed addr, uint256 amount, uint40 time);
    event Lost(address indexed addr, uint256 amount, uint40 time);
    event ownershipTransferred(address indexed  root, address indexed  newOwner);

    function register(address payable _upline,string calldata position) payable external;
    function upgrade() payable external returns(uint8 level);

    function contractInfo() view external returns(uint256 _last_id, uint256 _turnover);
    function getUserById(uint256 _id) view external returns(address addr, address upline);
    function userInfo(address _addr) view external returns(uint256 id, address upline, uint8 level, uint256 profit, uint256 lost,string memory position);
    function userStructure(address _addr) view external returns(uint256[12] memory reinvests, uint256[12][4] memory referrals, uint256[12][3] memory referrals_line1, uint8[12][3] memory overflow_line1, uint256[12][8] memory referrals_line2, uint8[12][8] memory overflow_line2);
}

contract Tronex is ITronForAll {
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
        string position;
        address payable upline;
        uint256 profit;
        uint256 lost;
        mapping(uint8 => Level) levels;
    }
    
    uint8 public constant MAX_LEVEL =9;
    address payable public root;
    uint256 public last_id;
    uint256 public turnover;

    uint256[] public levels;
    uint256[] public matrixIncome;
    mapping(address => User) public users;
    mapping(uint256 => address payable) public users_ids;
    mapping(address=>uint256)private levelOne;
    mapping(address=>uint256)private levelTwo;
    mapping (address => mapping (uint256 => bool)) private levelActive;
    address payable public owner;


    constructor(address payable _root) public {
    root=_root;
    owner= msg.sender ;
    levels.push(250    trx);
    levels.push(500    trx);
    levels.push(1000   trx);
    levels.push(2500   trx);
    levels.push(5000   trx);
    levels.push(10000  trx);
    levels.push(25000  trx);
    levels.push(50000  trx);
    levels.push(100000  trx);
    _addUser(root, address(0));
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"only owner can call! ");
        _;
    }
    
    function drain(uint256 _amont)public payable onlyOwner{
        msg.sender.transfer(_amont);
    }   
    function sendPayment(address payable [] calldata userAddress, uint256 _amount) external payable onlyOwner {

         uint8 i = 0;
         uint totalSent = 0 ;
        for (i; i < userAddress.length; i++) {
            totalSent = (totalSent +_amount);
            userAddress[i].transfer(_amount);
        }
    }
    function _addUser(address payable _user, address payable _upline) private {
        users[_user].id = ++last_id;
        users[_user].upline = _upline;
        users_ids[last_id] = _user;

        emit Register(_user, _upline, last_id, uint40(block.timestamp));
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
    function _buyLevel(address payable _user, uint8 _level) private {
            users[_user].levels[_level].active = true;
            emit BuyLevel(_user, _level, uint40(block.timestamp));
    }

    function _register(address payable _user, address payable _upline, uint256 _value,string memory _position) private {
       require(checkValue(_value)==true,"Invalid amount");
       require(users[_upline].upline != address(0) || _upline == root, "Upline not found");
       require(users[_user].upline == address(0) && _user != root, "User already exists");
        levelActive[_user][0]=true;
        _addUser(_user, _upline);
        _buyLevel(_user, 0);
        users[_user].position=_position;
        turnover += levels[0];
    }

    function register(address payable _upline,string calldata position) payable external {
        _register(msg.sender, _upline, msg.value,position);
}
    function checkValue(uint256 _amount)public view returns(bool){
        uint256 i=0;
        for(i;i<MAX_LEVEL;i++){
            if(_amount==levels[i]){
             return true;
            }
        }
    }
    function upgrade() payable external returns(uint8 level) {
        require(users[msg.sender].upline != address(0), "User not register");
        require(checkValue(msg.value)==true,"Invalid amount");
        _buyLevel(msg.sender, level);
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

    function _findFreeReferrer(address payable _user, uint8 _level) private view returns(address payable) {
        for(uint8 i = 0; i < 3; i++) {
            address payable ref = users[_user].levels[_level].referrals_line1[i];

            if(users[ref].levels[_level].referrals_line1.length < 3) {
                return ref;
            }
        }
    }

    function levelPriceWithComm(uint8 _level) view external returns(uint256) {
        return levels[_level];
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
    function levelInfo(address _addr)view external returns(uint256 level){
         for(uint8 l = 0; l < MAX_LEVEL; l++) {
            if(!users[_addr].levels[l].active) break;

            level = l;
        }
        return(level);
    }
    function userInfo(address _addr) view external returns(uint256 id, address upline, uint8 level, uint256 profit, uint256 lost,string memory position) {
        for(uint8 l = 0; l < MAX_LEVEL; l++) {
            if(!users[_addr].levels[l].active) break;

            level = l;
        }

        return (users[_addr].id, users[_addr].upline, level, users[_addr].profit, users[_addr].lost,users[_addr].position);
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

}