//SourceUnit: ImplmentationV1.sol

pragma solidity >=0.4.23 <0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

contract ImplementationV1 {
    using SafeMath for *;
    address public implementation;
    struct USER {
        uint256 id;
        uint partnersCount;
        uint256 referrer;
        mapping(uint256 => MATRIX) Matrix;
        mapping(uint256 => POOL) Pool;
        mapping(uint256 => bool) activeLevel;
    }
    struct MATRIX {
        address payable currentReferrer;
        address [] referrals;
        uint downLineCount;
        uint reinvestCount;
    }
    struct POOL {
        uint shares;
        bool is_in_pool;
    }

    uint    public pool_count = 1;
    uint    public pool_closing = 1 days;
    uint    public pool_last_closing = now;
    uint256 public maxDownLimit = 5;
    uint256 public lastIDCount = 0;
    uint256 public tronxPoolShare = 10;
    
    
    uint256 public mdPoolShare = 10;
    uint256 public companyPoolShare = 10;
    uint256 public leaderPoolShare = 5;

    uint256 public incomeDivider = 100;
    
    uint    public LAST_LEVEL = 9;
    
    mapping(uint256 => address payable[] ) public pool_users;
    mapping(uint256 => uint256) public pool_amount;
    mapping(uint256 => uint256) public total_shares;
    mapping(address => USER)    public users;
    mapping(uint256 => uint256) public LevelPrice;
    mapping(uint256 => address payable) public FreeIncome;
    mapping(uint256 => uint256) public LevelIncome;

    event Registration(address userAddress, uint256 accountId, uint256 refId);
    event NewUserPlace(uint256 accountId, uint256 refId, uint place, uint level);
    event UnilevelIncome(uint256 accountId, uint256 from, uint level, uint256 amount, uint networkLevel);
    event PoolIncome(uint256 accountId, uint level, uint256 amount, uint time);
    event Reinvest(address userAddress, address indexed caller, uint8 level);
    event PoolEnter(uint256 accountId, uint now, uint pool_id);

    address payable public owner;
    address payable public mdPool;
    address payable public companyPool;
    address payable public leaderPool;
    address payable public freePool;

    address public deployer;

    modifier onlyDeployer() {
        require(msg.sender == deployer);
        _;
    }

    mapping(uint256 => address payable) public userAddressByID;

    constructor(
        address payable _mdPool, 
        address payable _companyPool, 
        address payable _leaderPool,
        address payable _free1,
        address payable _free2,
        address payable _free3,
        address payable _free4,
        address payable _freePool
        ) public {

        owner = _companyPool;
        deployer = msg.sender;
        
        mdPool = _mdPool;
        companyPool = _companyPool;
        leaderPool = _leaderPool;
        freePool = _freePool;

        LevelPrice[1] =  1000000;

        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            LevelPrice[i] = LevelPrice[i-1] * 2;
        }   
        
        FreeIncome[1] = _free1;
        FreeIncome[2] = _free2;
        FreeIncome[3] = _free3;
        FreeIncome[4] = _free4;

        LevelIncome[1] = 50;
        LevelIncome[2] = 7;
        LevelIncome[3] = 4;
        LevelIncome[4] = 2;
        LevelIncome[5] = 2;

        lastIDCount++;

        USER memory user = USER({
            id: lastIDCount,
            referrer: 0,
            partnersCount: uint(0)
        });
        
        users[_companyPool] = user;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[_companyPool].activeLevel[i] = true;
        }

        userAddressByID[lastIDCount] = _companyPool;
    }

    function registrationExt(uint256 _referrerID) external payable {
        registration(msg.sender, _referrerID);
    }

    function registration(address payable userAddress, uint256 _referrerID) private {
        
        uint256 originalReferrer = _referrerID;
        uint8 _level = 1;
        
        require(msg.value == LevelPrice[_level], "Wrong Value");
        require(!isUserExists(userAddress), "user exists");
        require(_referrerID > 0 && _referrerID <= lastIDCount,"Incorrect referrer Id");

        uint32 size;
        
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        lastIDCount++;

        USER memory user = USER({
            id: lastIDCount,
            referrer: originalReferrer,
            partnersCount: uint(0)
        });

        users[userAddress] = user;
        users[userAddressByID[originalReferrer]].partnersCount++;
        
        
        userAddressByID[lastIDCount] = userAddress;
        _referrerID = findFreeReferrer(userAddress, _level);
        
        users[userAddress].Matrix[_level].currentReferrer = userAddressByID[_referrerID];
        users[userAddress].activeLevel[_level] = true;

        emit Registration(userAddress, lastIDCount, originalReferrer);
        
        leaderPool.transfer(LevelPrice[_level] * leaderPoolShare / incomeDivider);
        companyPool.transfer(LevelPrice[_level] * companyPoolShare / incomeDivider);
        mdPool.transfer(LevelPrice[_level] * mdPoolShare / incomeDivider);

        pool_amount[_level] += LevelPrice[_level] / tronxPoolShare;

        handlePools(userAddressByID[originalReferrer], _level);
        
    
        updateReferrer(userAddress, userAddressByID[_referrerID], _level);
    }
    
    function buyLevel(uint8 _level) external payable {
        require(_level > 1 && _level <= LAST_LEVEL, "Wrong Level");
        require(msg.value == LevelPrice[_level], "Wrong Value");
        require(isUserExists(msg.sender), "User Not Exit");
        require(users[msg.sender].activeLevel[_level] == false, "Level Activated");
        require(users[msg.sender].activeLevel[_level - 1], "Previous level not active");

        leaderPool.transfer(LevelPrice[_level] * leaderPoolShare / incomeDivider);
        companyPool.transfer(LevelPrice[_level] * companyPoolShare / incomeDivider);
        mdPool.transfer(LevelPrice[_level] * mdPoolShare / incomeDivider);
        
        pool_amount[_level] += LevelPrice[_level] / tronxPoolShare;

        uint256 _referrerID = findFreeReferrer(msg.sender, _level);
           
        users[msg.sender].Matrix[_level].currentReferrer = userAddressByID[_referrerID];
        users[msg.sender].activeLevel[_level] = true;

        handlePools(userAddressByID[users[msg.sender].referrer], _level);
        updateReferrer(msg.sender, userAddressByID[_referrerID], _level);
    }
    
    function handlePools(address payable refOrg, uint8 _level) private {
        if(users[refOrg].activeLevel[_level])
        {
            users[refOrg].Matrix[_level].downLineCount++;
        
            if(users[refOrg].Matrix[_level].downLineCount >= maxDownLimit) {
                uint shares_temp = users[refOrg].Matrix[_level].downLineCount.div(maxDownLimit);
                
                if(users[refOrg].Pool[_level].is_in_pool == false) {
                    emit PoolEnter(users[refOrg].id, now, pool_count);
                    users[refOrg].Pool[_level].is_in_pool = true;
                    pool_users[_level].push(refOrg);
                }
                
                if(shares_temp > users[refOrg].Pool[_level].shares) {
                    users[refOrg].Pool[_level].shares += shares_temp;
                    total_shares[_level] += shares_temp;
                }
            }
        }
        
    }
    function poolClosing(uint8 _level) external onlyDeployer {

        if(pool_amount[_level] > 0) {
            uint256 perShareValue = pool_amount[_level] / total_shares[_level];
                    
            if(pool_users[_level].length > 0) {

                for(uint i = 0 ; i < pool_users[_level].length; i++) {
                    address payable userAddress = pool_users[_level][i];

                    if(userAddress != address(0))
                    {
                        uint256 userAmount = users[userAddress].Pool[_level].shares * perShareValue;
                    
                        emit PoolIncome(users[userAddress].id, _level, userAmount, now);
                        
                        if(!address(uint160(userAddress)).send(userAmount)) {
                            address(uint160(userAddress)).transfer(userAmount);
                        }
                        
                        users[userAddress].Pool[_level].shares = 0;
                        users[userAddress].Pool[_level].is_in_pool = false;
                    }
                }
            }
            else {
                if(!address(uint160(freePool)).send(pool_amount[_level])) {
                    address(uint160(freePool)).transfer(pool_amount[_level]);
                }
            }
            
            pool_count++;
            pool_users[_level] = new address payable[](0);
            
            pool_amount[_level] = 0;
            total_shares[_level] = 0;

            if(_level == LAST_LEVEL){
                pool_last_closing = now.add(pool_closing);
            }
        }
        
    }
    
    function updateReferrer(address payable userAddress, address payable referrerAddress, uint8 level) private {
        users[referrerAddress].Matrix[level].referrals.push(userAddress);

        emit NewUserPlace(users[userAddress].id, users[referrerAddress].id, users[referrerAddress].Matrix[level].referrals.length, level);

        if(users[referrerAddress].Matrix[level].referrals.length < 5) {
            incomeDistribution(userAddress, referrerAddress, level);
        }
        else {
            users[referrerAddress].Matrix[level].referrals = new address[](0);
            
            emit Reinvest(referrerAddress, userAddress, level);
            
            users[referrerAddress].Matrix[level].reinvestCount++;

            if(referrerAddress  != owner) {
                uint _referrerID = findFreeReferrer(referrerAddress, level);
                
                if(users[referrerAddress].Matrix[level].currentReferrer != userAddressByID[_referrerID]) {
                    users[referrerAddress].Matrix[level].currentReferrer = userAddressByID[_referrerID];
                }

                updateReferrer(referrerAddress, userAddressByID[_referrerID], level);
            }
            else {
                incomeDistribution(userAddress, referrerAddress, level);
            }
        }
    }
    
    function incomeDistribution(address payable userAddress, address payable _upline, uint8 _level) private {
        for(uint i = 1; i <= 5; i++) {

            uint256 income = LevelPrice[_level] * LevelIncome[i] / 100;
            
            if(_upline != address(0)) {

                emit UnilevelIncome(users[_upline].id, users[userAddress].id, _level, income, i);
                
                if(!address(uint160(_upline)).send(income)) {
                    address(uint160(_upline)).transfer(income);
                }
                       
                _upline = users[_upline].Matrix[_level].currentReferrer;
            }
            else {
                if(!address(uint160(FreeIncome[i - 1])).send(income)) {
                    address(uint160(FreeIncome[i - 1])).transfer(income);
                }
            }
        }
    }
    
    function findFreeReferrer(address userAddress, uint8 level) internal view returns(uint256) {
        while (true) {
            if (users[userAddressByID[users[userAddress].referrer]].activeLevel[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = userAddressByID[users[userAddress].referrer];
        }
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function getUserMatrix(address user, uint8 _level) public view returns (address payable referrer, address[] memory referrals, uint downLineCount, uint reinvestCount ) {
        return (users[user].Matrix[_level].currentReferrer, users[user].Matrix[_level].referrals, users[user].Matrix[_level].downLineCount, users[user].Matrix[_level].reinvestCount);
    }
    
    function getUserPool(address user, uint8 _level) public view returns (uint shares, bool is_in_pool ) {
        return (users[user].Pool[_level].shares, users[user].Pool[_level].is_in_pool);
    }
    
    function getAllPoolUsers(uint8 _level) public view returns(address payable[] memory all_users) {
        return pool_users[_level];
    }
    function getPoolDrawPendingTime() public view returns(uint) {
        uint remainingTimeForPayout = 0;

        if(pool_last_closing + pool_closing >= now) {
            uint temp = pool_last_closing + pool_closing;
            remainingTimeForPayout = temp.sub(now);
        }
        return remainingTimeForPayout;
    }
}