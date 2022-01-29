//SourceUnit: tronHubs.sol

pragma solidity 0.5.10;

 
contract owned {
    address  public owner;
    address  internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {

    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address  _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


interface ext
{
    function getFund(uint amount) external returns(bool);
}

contract TronHub is owned
{

    uint public maxDownLimit = 5;

    uint public lastIDCount;
    
    uint public defaultRefID = 1; 

    uint[20] public levelPrice;

    uint[16] public levelPayPrice;

    // totalCount => level => userID;
    mapping(uint => mapping(uint => uint)) public indexToID;
    // level => totalPosition
    mapping(uint => uint) public totalPosition;

    struct userInfo {
        bool joined;
        uint id;
        uint origRef;
        uint levelBought;
        uint directCount;
        bool booster;
        uint boosterLevel;
        address[] referral;
    }

    struct RecycleInfo {
        uint currentParent;
        uint position;
        address[] childs;
    }
    mapping (address => userInfo) public userInfos;
    mapping (uint => address ) public userAddressByID;

    mapping (address => mapping(uint => RecycleInfo)) public activeRecycleInfos;
    mapping (address => mapping(uint => RecycleInfo[])) public archivedRecycleInfos;

    uint64[20] public nextMemberFillIndex;  // which auto pool index is in top of queue to fill in 
    uint64[20] public nextMemberFillBox;   // 4 downline to each, so which downline need to fill in    

    //event directPaidEv(uint from,uint to, uint amount, uint level, uint timeNow);
    event payForLevelEv(uint _userID,uint parentID,uint amount,uint fromDown, uint timeNow);
    event regLevelEv(uint _userID,uint _referrerID,uint timeNow,address _user,address _referrer);
    event levelBuyEv(uint amount, uint toID, uint level, uint timeNow);
    event placingEv (uint userid,uint ParentID,uint amount,uint position, uint level, uint timeNow);
    event regUserPlacingEv (uint userid,uint ParentID,uint amount,uint position, uint level, uint timeNow);
    event buyLevelPlacingEv (uint userid,uint ParentID,uint amount,uint position, uint level, uint timeNow);
    constructor() public {
        owner = msg.sender;
            
        levelPrice[1] = 100000000;

        levelPrice[2] = 150000000;
        levelPrice[3] = 250000000;
        levelPrice[4] = 500000000;
        levelPrice[5] = 1000000000;
        levelPrice[6] = 2500000000;
        levelPrice[7] = 5000000000;
        levelPrice[8] = 10000000000;
        levelPrice[9] = 25000000000;
        levelPrice[10]= 50000000000;
        levelPrice[11]= 100000000000;
        
        levelPrice[12]= 2500000000;
        levelPrice[13]= 7500000000;
        levelPrice[14]= 25000000000;

        levelPayPrice[1] = 50000000;
        levelPayPrice[2] = 10000000;
        levelPayPrice[3] = 5000000;
        levelPayPrice[4] = 3000000;
        levelPayPrice[5] = 2000000;
        levelPayPrice[6] = 1000000;
        levelPayPrice[7] = 1000000;
        levelPayPrice[8] = 1000000;
        levelPayPrice[9] = 1000000;
        levelPayPrice[10]= 1000000;

        userInfo memory UserInfo;
        lastIDCount++;

        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            origRef:lastIDCount,            
            levelBought:14,
            directCount:100,
            booster:true,
            boosterLevel: 3,
            referral: new address[](0)
        });
        userInfos[owner] = UserInfo;
        userAddressByID[lastIDCount] = owner;
        

        RecycleInfo memory temp;
        temp.currentParent = 1;
        temp.position = 0;
        for(uint i=1;i<=14;i++)
        {
            activeRecycleInfos[owner][i] = temp;
            indexToID[1][i] = 1;
            totalPosition[i] = 1;
            //nextMemberFillIndex[i] = 1;
        }
    }

    function ()  external payable {
        
    }

    function regUser(uint _referrerID) public payable returns(bool)
    {
        require(!userInfos[msg.sender].joined, "already joined");
        require(msg.value == levelPrice[1], "Invalid price paid");
        if(! (_referrerID > 0 && _referrerID <= lastIDCount) ) _referrerID = 1;
        address origRef = userAddressByID[_referrerID];
        (uint _parentID, uint position)  = findFreeParentInDown(1);
        _parentID = indexToID[_parentID][1];


        lastIDCount++;
        totalPosition[1]++;
        indexToID[totalPosition[1]][1] = lastIDCount;
        userInfo memory UserInfo;
        UserInfo = userInfo({
            joined: true,
            id: lastIDCount,
            origRef:_referrerID,            
            levelBought:1,
            directCount:0,
            booster:false,
            boosterLevel:0,
            referral: new address[](0)
        });
        userInfos[msg.sender] = UserInfo;
        userAddressByID[lastIDCount] = msg.sender;
        userInfos[origRef].referral.push(msg.sender);

        userInfos[origRef].directCount++;      

        RecycleInfo memory temp;
        temp.currentParent = _parentID;

        temp.position = position;
        activeRecycleInfos[msg.sender][1] = temp;
        activeRecycleInfos[userAddressByID[_parentID]][1].childs.push(msg.sender);

        processPayMain(msg.sender);
        //if(position == 5)recyclePosition(_parentID, 1);

        emit regLevelEv(lastIDCount,_referrerID,now, msg.sender,userAddressByID[_referrerID]);
        emit regUserPlacingEv (lastIDCount,_parentID,levelPrice[1],position, 1, now);
        return true;
    }


    event processPayMainEv(uint paidTo, uint  paidAgainst, uint _level,uint amount, uint timeNow);
    function processPayMain(address _user) internal returns(bool)
    {
        address ref = userAddressByID[userInfos[_user].origRef];
        for(uint i=0;i<10;i++)
        {
            address(uint160(ref)).transfer(levelPayPrice[i+1]);
            emit processPayMainEv(userInfos[ref].id,userInfos[_user].id,i+1, levelPayPrice[i+1],now);
            ref = userAddressByID[userInfos[ref].origRef];
        }
        address(uint160(owner)).transfer(25000000);
        return true;
    }


    event paidForLevelEv_(uint toID,uint fromID, uint amount, uint level, uint position, uint timeNow, uint itype);
    function processPosition_(address _ref, uint position, uint _level,uint fromID) internal returns(bool)
    {
        address origRef = userAddressByID[userInfos[userAddressByID[fromID]].origRef];
        if(userInfos[origRef].boosterLevel >= _level) 
        {

            address(uint160(origRef)).transfer(levelPrice[_level+11] / 5);
            emit paidForLevelEv(userInfos[origRef].id,fromID,  levelPrice[_level+11]/5, _level, position, now, 1);
        }
        else
        {
            address(uint160(owner)).transfer(levelPrice[_level+11] / 5);
            emit paidForLevelEv(userInfos[owner].id,fromID,  levelPrice[_level+11]/5, _level, position, now, 1);            
        }

        if(userInfos[_ref].boosterLevel >= _level) 
        {
            address(uint160(_ref)).transfer(levelPrice[_level+11] *4 / 5);
            emit paidForLevelEv(userInfos[_ref].id,fromID,  levelPrice[_level+11]*4/5, _level, position, now, 2);
        }
        else 
        {
            address(uint160(owner)).transfer(levelPrice[_level+11] * 4 / 5);
            emit paidForLevelEv(userInfos[owner].id,fromID,  levelPrice[_level+11]*4/5, _level, position, now, 2);
        }

        return true;
    }

    function findFreeParentInDown(uint _level) internal returns(uint parentID,uint position)
    {
        if(nextMemberFillIndex[_level] == 0) nextMemberFillIndex[_level]=1; 
        if(nextMemberFillBox[_level] <= 3)
        {
            nextMemberFillBox[_level] ++;
            return (nextMemberFillIndex[_level], nextMemberFillBox[_level]);
        }   
        else
        {
            nextMemberFillIndex[_level]++;
            nextMemberFillBox[_level] = 0;

            uint idx = nextMemberFillIndex[_level];
            uint _ID = indexToID[idx][_level];
            uint child = activeRecycleInfos[userAddressByID[_ID]][_level].childs.length;

            while(child == 5 )
            {
                nextMemberFillIndex[_level]++;
                idx = nextMemberFillIndex[_level];
                _ID = indexToID[idx][_level];
                child = activeRecycleInfos[userAddressByID[_ID]][_level].childs.length;                
            }

            if (child > 0 && child < 4 ) 
            {
                nextMemberFillBox[_level] = uint64(child);
                return  (nextMemberFillIndex[_level] - 1,  nextMemberFillBox[_level] - 1);
            }
            else
            {
                return  (nextMemberFillIndex[_level] - 1, 5);
            }           
           
        }
                
    }

    function findFreeParentInDown_(uint  refID_ , uint _level) public view returns(uint parentID, uint position)
    {
        address _user = userAddressByID[refID_];
        return (refID_, activeRecycleInfos[_user][_level].childs.length+1);

    }


    event boughtLevelEv(uint id, uint level, uint position);
    event paidForLevelEv(uint toID,uint fromID, uint amount, uint level, uint position, uint timeNow, uint itype);

    function processPosition(address _ref, uint position, uint _level,uint fromID) internal returns(bool)
    {
            if(position < 5)
            {
                address(uint160(_ref)).transfer(levelPrice[_level] / 2);
                emit paidForLevelEv(userInfos[_ref].id,fromID,  levelPrice[_level], _level, position, now, 0);                 
            }
            else if(position == 5)
            {              
                 recyclePosition(userInfos[_ref].id, _level);
            } 

        return true;
    }

    function buyLevel( uint _level, address _leveladdress) public payable returns(bool)
    {
        require(userInfos[msg.sender].joined, "pls register first");
        require(_level > 1 && _level <= 14, "Invalid level");
        require(msg.value == levelPrice[_level], "Invalid amount paid");
        address msgsender = msg.sender;
        if(_level > 11 ) 
        {
            require(userInfos[msg.sender].levelBought >= 3 , "pls buy level 2 and 3");
            require(userInfos[msg.sender].boosterLevel == _level - 12, "Invalid booster level");
        }
        
        totalPosition[_level]++;
        indexToID[totalPosition[_level]][_level] = userInfos[msgsender].id;

        (uint _parentID, uint position)  = findFreeParentInDown(_level);
        _parentID = indexToID[_parentID][_level];

        if(_level <= 11 ) 
        {
            userInfos[msgsender].levelBought = _level; 
        }
        else
        {
            userInfos[msgsender].boosterLevel = _level - 11;
        }

        RecycleInfo memory temp;
        temp.currentParent = _parentID;
        //uint position = activeRecycleInfos[userAddressByID[_parentID]][_level].childs.length + 1;
        temp.position = position;
        activeRecycleInfos[msgsender][_level] = temp;
        activeRecycleInfos[userAddressByID[_parentID]][_level].childs.push(msgsender);
        
        if (_level <= 11) 
        {
            //require(processPosition(userAddressByID[_parentID], position,_level, userInfos[msgsender].id), "porcess fail 2");
             address(uint160(_leveladdress)).transfer(msg.value / 2);
             emit paidForLevelEv(userInfos[_leveladdress].id,userInfos[msgsender].id,  levelPrice[_level]/2, _level, position, now, 3);
                //direct payout
            address origRef = userAddressByID[userInfos[msg.sender].origRef];
            if(userInfos[origRef].levelBought >= _level)
            { 
                address(uint160(origRef)).transfer(msg.value / 2);
                emit paidForLevelEv(userInfos[origRef].id,userInfos[msgsender].id,  levelPrice[_level]/2, _level, position, now, 1);
            }
            else
            {
                address(uint160(owner)).transfer(msg.value / 2);
                emit paidForLevelEv(userInfos[owner].id,userInfos[msgsender].id,  levelPrice[_level]/2, _level, position, now, 1);                
            }
        }
        else
        {
            require(processPosition_(userAddressByID[_parentID], position,_level-11, userInfos[msgsender].id), "porcess fail 2");
        }
        emit levelBuyEv(levelPrice[_level], userInfos[msgsender].id,_level, now);
        emit buyLevelPlacingEv (userInfos[msgsender].id,_parentID,levelPrice[_level],position, _level, now);
        return true;
    }


    function recyclePosition(uint _userID, uint _level)  internal returns(bool)
    {

        address msgSender = userAddressByID[_userID];

        archivedRecycleInfos[msgSender][_level].push(activeRecycleInfos[msgSender][_level]); 
        
        totalPosition[_level]++;
        indexToID[totalPosition[_level]][_level] = _userID;

        (uint _parentID, uint position)  = findFreeParentInDown_(userInfos[msgSender].origRef, _level);
        _parentID = indexToID[_parentID][_level];       

        RecycleInfo memory temp;
        temp.currentParent = _parentID;
        //uint position = activeRecycleInfos[userAddressByID[_parentID]][_level].childs.length + 1;
        temp.position = position;
        activeRecycleInfos[msgSender][_level] = temp;
        activeRecycleInfos[userAddressByID[_parentID]][_level].childs.push(msgSender);
        emit placingEv (_userID,_parentID,levelPrice[_level],position, _level, now);        
        
        require(processPosition(userAddressByID[_parentID], position,_level, _userID), "porcess fail 3");

        return true;
    }

    function getValidRef(address _user, uint _level) public view returns(uint)
    {
        uint refID = userInfos[_user].origRef;
        uint lvlBgt = userInfos[userAddressByID[refID]].levelBought;

        while(lvlBgt < _level)
        {
            refID = userInfos[userAddressByID[refID]].origRef;
            lvlBgt = userInfos[userAddressByID[refID]].levelBought;
        }
        return refID;
    }

}