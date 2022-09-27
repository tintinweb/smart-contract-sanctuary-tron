//SourceUnit: tron.sol

pragma solidity 0.5.9;

contract ChainOfFavors {
    
    struct User {
        uint id;
        address referrer;
        uint inviteCounts;
        mapping(uint8 => bool) activeLevels;
        mapping(uint8 => theMatrix) Matrix;
    }
    
    struct theMatrix {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint256 reinvestCount;
    }


    uint8 public constant LAST_LEVEL = 24;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 1;
    address public doner;
    address private owner1;
    address private owner2;
    address private owner3;
    address private owner4;
    address public deployer;
    uint256 public contractDeployTime;
    
    mapping(uint256 => uint256) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId, uint amount);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint amount);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    
    constructor(address donerAddress, address Owner1,  address Owner2,  address Owner3,  address Owner4) public {
        levelPrice[1] = 250 * 1e6;
        uint256 x = 0;
        for (uint256 i = 0; i < 6; i++) {
        for (uint256 j = 0; j < 4; j++) {
            x+=1;
            levelPrice[x] = (levelPrice[1] * uint256(2) ** j) * (uint256(10) ** i);
        }
        }
        uint8 i;
       /* levelPrice[1] = 350 * 1e6;
        for (i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }*/
        deployer = msg.sender;
        doner = donerAddress;
        owner1 = Owner1;
        owner2 = Owner2;
        owner3 = Owner3;
        owner4 = Owner4;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            inviteCounts: uint(0)
        });
        
        users[donerAddress] = user;
        idToAddress[1] = donerAddress;
        
        for (i = 1; i <= LAST_LEVEL; i++) {
            users[donerAddress].activeLevels[i] = true;
        }

        userIds[1] = donerAddress;
        
        contractDeployTime = now;
        
        emit Registration(donerAddress, address(0), 1, 0, 0);
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, doner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable returns(string memory) {
        registration(msg.sender, referrerAddress);
        return "registration successful";
    }
    
    function registrationCreator(address userAddress, address referrerAddress) external returns(string memory) {
        require(msg.sender==deployer, 'Invalid Donor');
        require(contractDeployTime+86400 > now, 'This function is only available for first 24 hours' );
        registration(userAddress, referrerAddress);
        return "registration successful";
    }
    
    function buyLevelCreator(address userAddress, uint8 matrix, uint8 level) external returns(string memory) {
        require(msg.sender==deployer, 'Invalid Donor');
        require(contractDeployTime+86400 > now, 'This function is only available for first 24 hours' );
        buyNewLevelInternal(userAddress, matrix, level);
        return "Level bought successfully";
    }
    
    function buyNewLevel(uint8 matrix, uint8 level) external payable returns(string memory) {
        buyNewLevelInternal(msg.sender, matrix, level);
        return "Level bought successfully";
    }
    
    function buyNewLevelInternal(address user, uint8 matrix, uint8 level) private {
        require(isUserExists(user), "user is not exists. Register first.");
        require(matrix == 1, "invalid matrix");
        if(!(msg.sender==deployer)) require(msg.value == levelPrice[level], "invalid price");
        require(level >= 1 && level <= LAST_LEVEL, "invalid level");
        if (levelPrice[level] % 25 == 0 && level != 1) {
            require(users[user].activeLevels[1], "unavailable vertical level");
        } 
            
        if (levelPrice[level] % 25 != 0 && level > 1) {
            require(users[user].activeLevels[1], "unavailable horizontal level");
        } 
        

            require(!users[user].activeLevels[level], "level already activated");

            if (users[user].Matrix[level-1].blocked) {
                users[user].Matrix[level-1].blocked = false;
            }
    
            address freeReferrer = findFreeReferrer(user, level);
            users[user].Matrix[level].currentReferrer = freeReferrer;
            users[user].activeLevels[level] = true;
            updateReferrer(user, freeReferrer, level);
            
            emit Upgrade(user, freeReferrer, 1, level, msg.value);

    }    
    
    function registration(address userAddress, address referrerAddress) private {
        if(!(msg.sender==deployer)) require(msg.value == 50 * 1e6, "Invalid registration amount");       
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        lastUserId++;
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            inviteCounts: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        userIds[lastUserId] = userAddress;
        
        
        users[referrerAddress].inviteCounts++;

        address freeReferrer = findFreeReferrer(userAddress, 1);
        users[userAddress].Matrix[1].currentReferrer = freeReferrer;
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id, msg.value);
    }
    
    function updateReferrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeLevels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != doner) {
            //check referrer active level
            address freeReferrerAddress = findFreeReferrer(referrerAddress, level);
            if (users[referrerAddress].Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateReferrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(doner, userAddress, 1, level);
            users[doner].Matrix[level].reinvestCount++;
            emit Reinvest(doner, address(0), userAddress, 1, level);
        }
    }
    
    function findFreeReferrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeLevels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }

        
    function usersActiveLevels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeLevels[level];
    }


    function usersMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool, uint256) {
        return (users[userAddress].Matrix[level].currentReferrer,
                users[userAddress].Matrix[level].referrals,
                users[userAddress].Matrix[level].blocked,
                users[userAddress].Matrix[level].reinvestCount);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        if(msg.sender!=deployer)
        {
            (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);


            if (address(uint160(receiver)) == address(uint160(doner))) {
                address(uint160(owner1)).transfer(address(this).balance / 4);
                address(uint160(owner2)).transfer(address(this).balance / 4);
                address(uint160(owner3)).transfer(address(this).balance / 4);
                return address(uint160(owner4)).transfer(address(this).balance / 4);
            }
            
            if (!address(uint160(receiver)).send(levelPrice[level])) {
                return address(uint160(receiver)).transfer(address(this).balance);
            }
        
            if (isExtraDividends) {
                emit SentExtraEthDividends(_from, receiver, matrix, level);
            }
        }
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function viewLevels(address user) public view returns (bool[12] memory Levels,uint8 LastTrue)
    {
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            Levels[i] = users[user].activeLevels[i];
            if(Levels[i]) LastTrue = i;
        }
    }


    

}