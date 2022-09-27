//SourceUnit: SmartBitPointTron.sol

/*
╔═══╗╔═╗╔═╗╔═══╗╔═══╗╔════╗╔══╗─╔══╗╔════╗╔═══╗╔═══╗╔══╗╔═╗─╔╗╔════╗
║╔═╗║║║╚╝║║║╔═╗║║╔═╗║║╔╗╔╗║║╔╗║─╚╣─╝║╔╗╔╗║║╔═╗║║╔═╗║╚╣─╝║║╚╗║║║╔╗╔╗║
║╚══╗║╔╗╔╗║║║─║║║╚═╝║╚╝║║╚╝║╚╝╚╗─║║─╚╝║║╚╝║╚═╝║║║─║║─║║─║╔╗╚╝║╚╝║║╚╝
╚══╗║║║║║║║║╚═╝║║╔╗╔╝──║║──║╔═╗║─║║───║║──║╔══╝║║─║║─║║─║║╚╗║║──║║──
║╚═╝║║║║║║║║╔═╗║║║║╚╗──║║──║╚═╝║╔╣─╗──║║──║║───║╚═╝║╔╣─╗║║─║║║──║║──
╚═══╝╚╝╚╝╚╝╚╝─╚╝╚╝╚═╝──╚╝──╚═══╝╚══╝──╚╝──╚╝───╚═══╝╚══╝╚╝─╚═╝──╚╝──
international telegram channel: @smartbitpoint
international telegram group: @smartbitpoint_com
international telegram bot: @smartbitpoint_bot
hashtag: #smartbitpoint
*/
pragma solidity >=0.5.10 <0.7.0;

contract SmartBitPoint {
    uint public currUserID = 1;
    address private lastUser;
    address private owner; address private manager;
    uint public START_PRICE = 300 trx;
    mapping (uint => uint) public StatsLevel;
    struct User {
        uint id;
        uint currentLevel;
        bool unlimited;
        uint referrerB; uint referrerT; uint referrerL;
        address[] referralsB; address[] referralsT; address[] referralsL;
        mapping (uint => uint) countGetMoney; mapping (uint => uint) countLostMoney;
    }
    mapping (address => User) public mapusers;
    mapping (uint => address) public usersAddress;
    bool private ContractInit;

    event regLevelEvent(address indexed _user, address indexed _referrer, uint indexed _type, uint _id, uint _time);
    event buyLevelEvent(address indexed _user, uint indexed _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint indexed _level, uint _time);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint indexed _level, uint _time);

    modifier onlyOwner { require(msg.sender == owner, "Only owner can call this function."); _; }
    modifier onlyOwnerOrManager { require(msg.sender == owner || msg.sender == manager, "Only owner or manager can call this function."); _; }
    modifier userRegistered(address _user) { require(mapusers[_user].id != 0, 'User does not exist'); _; }
    modifier validPrice(uint _price) { require(_price > 0 && _price % 3 == 0, 'Invalid price'); _; }
    modifier validAddress(address _user) { require(_user != address(0), "Zero address"); _; }

    constructor() public {
        require(!ContractInit,"This contract inited"); owner = msg.sender; manager = msg.sender;
        lastUser = owner;
        mapusers[owner] = User({ id: 1, currentLevel: 120, unlimited: true, referrerB: 0, referrerT: 0, referrerL: 0, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
        usersAddress[1] = owner;
        ContractInit = true;
    }

    function () external payable {
        uint level;
        if(msg.value == START_PRICE){
            level = 1;
        } else if(msg.value % 3 == 0){
            level = msg.value/START_PRICE;
        }
        require(level > 0, 'Invalid sum');

        uint32 size = _sGetA(msg.sender);
        require(size == 0, "Cannot be a contract");

        if(mapusers[msg.sender].id != 0){

            require(mapusers[msg.sender].unlimited == false, 'You have unlimited levels');
            if(mapusers[msg.sender].currentLevel >= level) revert('Level is already activated');
            if(mapusers[msg.sender].currentLevel+1 != level) revert('Buy previous level');
            mapusers[msg.sender].currentLevel = level;
            StatsLevel[level]++;
            payForLevel(level, msg.sender);
            emit buyLevelEvent(msg.sender, level, now);
        } else if(level == 1){
            address referrer = _bToA(msg.data);
            require(mapusers[referrer].id != 0, 'Incorrect referrer');

            uint bone = mapusers[referrer].id;
            uint two = mapusers[referrer].id;
            if(mapusers[referrer].referralsB.length >= 2)
                bone = mapusers[findFreeReferrerB(referrer)].id;
            if(mapusers[referrer].referralsT.length >= 3)
                two = mapusers[findFreeReferrerT(referrer)].id;
            currUserID++;
            mapusers[msg.sender] = User({ id: currUserID, currentLevel: 1, unlimited: false, referrerB: bone, referrerT: two, referrerL: mapusers[referrer].id, referralsB: new address[](0), referralsT: new address[](0), referralsL: new address[](0) });
            usersAddress[currUserID] = msg.sender;
            mapusers[usersAddress[bone]].referralsB.push(msg.sender);
            mapusers[usersAddress[two]].referralsT.push(msg.sender);
            mapusers[referrer].referralsL.push(msg.sender);
            StatsLevel[1]++;
            if(_aToP(usersAddress[bone]).send(msg.value/3)) {
                emit getMoneyForLevelEvent(usersAddress[bone], msg.sender, 1, now);
                mapusers[usersAddress[bone]].countGetMoney[1]++;
            }
            if(_aToP(usersAddress[two]).send(msg.value/3)) {
                emit getMoneyForLevelEvent(usersAddress[two], msg.sender, 1, now);
                mapusers[usersAddress[two]].countGetMoney[1]++;
            }
            if(_aToP(referrer).send(msg.value/3)) {
                emit getMoneyForLevelEvent(referrer, msg.sender, 1, now);
                mapusers[referrer].countGetMoney[1]++;
            }
            lastUser = msg.sender;
            emit regLevelEvent(msg.sender, usersAddress[bone], 1, currUserID, now);
            emit regLevelEvent(msg.sender, usersAddress[two], 2, currUserID, now);
            emit regLevelEvent(msg.sender, referrer, 3, currUserID, now);
        } else {
            revert('Buy first level');
        }
    }

    function payForLevel(uint _level, address _user) internal {
        address referrer;

        referrer = findFreeReferralB(_user,_level);
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, _user, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }

        referrer = findFreeReferralT(_user,_level);
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, _user, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }

        referrer = _user;
        while (true) {
            referrer = usersAddress[mapusers[referrer].referrerL];
            if(referrer == address(0)) { referrer = owner; break; }
            if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) break;
            emit lostMoneyForLevelEvent(referrer, _user, _level, now);
            mapusers[referrer].countLostMoney[_level]++;
        }
        if(_aToP(referrer).send(msg.value/3)) {
            emit getMoneyForLevelEvent(referrer, _user, _level, now);
            mapusers[referrer].countGetMoney[_level]++;
        }
    }

    function findFreeReferrerB(address _user) public view returns(address) {
        if(mapusers[_user].referralsB.length < 2) return _user;
        address[] memory referrals = new address[](1022);
        referrals[0] = mapusers[_user].referralsB[0];
        referrals[1] = mapusers[_user].referralsB[1];
        for(uint i=0; i<1022;i++){
            if(mapusers[referrals[i]].referralsB.length < 2) return referrals[i];
            if(i > 509) continue;
            referrals[(i + 1) * 2] = mapusers[referrals[i]].referralsB[0];
            referrals[(i + 1) * 2 + 1] = mapusers[referrals[i]].referralsB[1];
        }
        return lastUser;
    }
    function findFreeReferrerT(address _user) public view returns(address) {
        if(mapusers[_user].referralsT.length < 3) return _user;
        address[] memory referrals = new address[](1092);
        referrals[0] = mapusers[_user].referralsT[0];
        referrals[1] = mapusers[_user].referralsT[1];
        referrals[2] = mapusers[_user].referralsT[2];
        for(uint i=0; i<1092;i++){
            if(mapusers[referrals[i]].referralsT.length < 3) return referrals[i];
            if(i > 362) continue;
            referrals[(i + 1) * 3] = mapusers[referrals[i]].referralsT[0];
            referrals[(i + 1) * 3 + 1] = mapusers[referrals[i]].referralsT[1];
            referrals[(i + 1) * 3 + 2] = mapusers[referrals[i]].referralsT[2];
        }
        return lastUser;
    }

    function findFreeReferralB(address _user, uint _level) private returns(address) {
        uint height = _level;
        address referrer = _user;
        while (referrer != address(0)) {
            referrer = usersAddress[mapusers[referrer].referrerB];
            height--;
            if(height == 0){
                if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) return referrer;
                emit lostMoneyForLevelEvent(referrer, _user, _level, now);
                mapusers[referrer].countLostMoney[_level]++;
                height = _level;
            }
        }
        return owner;
    }
    function findFreeReferralT(address _user, uint _level) private returns(address) {
        uint height = _level;
        address referrer = _user;
        while (referrer != address(0)) {
            referrer = usersAddress[mapusers[referrer].referrerT];
            height--;
            if(height == 0){
                if(mapusers[referrer].currentLevel >= _level || mapusers[referrer].unlimited) return referrer;
                emit lostMoneyForLevelEvent(referrer, _user, _level, now);
                mapusers[referrer].countLostMoney[_level]++;
                height = _level;
            }
        }
        return owner;
    }

    function viewUserReferralsB(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsB;
    }
    function viewUserReferralsT(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsT;
    }
    function viewUserReferralsL(address _user) public view returns(address[] memory) {
        return mapusers[_user].referralsL;
    }

    function getCountGetMoney(address _user, uint _level) public view returns(uint) {
        return mapusers[_user].countGetMoney[_level];
    }
    function getCountLostMoney(address _user, uint _level) public view returns(uint) {
        return mapusers[_user].countLostMoney[_level];
    }

    function getUserInfo(address _user) public view returns(uint,uint,bool,uint[3] memory,address[3] memory){
        return (mapusers[_user].id,mapusers[_user].currentLevel,mapusers[_user].unlimited,
        [mapusers[_user].referrerB,mapusers[_user].referrerT,mapusers[_user].referrerL],
        [usersAddress[mapusers[_user].referrerB], usersAddress[mapusers[_user].referrerT],usersAddress[mapusers[_user].referrerL]]);
    }

    function setStartPrice(uint _price) public onlyOwnerOrManager validPrice(_price) {
        START_PRICE = _price * 0.001 trx;
    }
    function setUserUnlimited(address _user) public onlyOwnerOrManager userRegistered(_user) {
        mapusers[_user].unlimited = true;
    }
    function delUserUnlimited(address _user) public onlyOwnerOrManager userRegistered(_user) {
        mapusers[_user].unlimited = false;
    }

    function setOwner(address _user) public onlyOwner validAddress(_user) { owner = _user; }
    function setManager(address _user) public onlyOwnerOrManager validAddress(_user) { manager = _user; }
    function getOwner() external view returns (address) { return owner; }
    function getManager() external view returns (address) { return manager; }
    function _bToA(bytes memory _bys) internal pure returns(address addr) { assembly { addr := mload(add(_bys, 20)) } }
    function _aToP(address _addr) internal pure returns(address payable) { return address(uint160(_addr)); }
    function _sGetA(address _addr) internal view returns(uint32 size) { assembly { size := extcodesize(_addr) } }
}