//SourceUnit: autoxify.sol

/*
www.autoxify.io
                     ___                                  .-.                
                    (   )                          .-.   /    \              
  .---.   ___  ___   | |_       .--.    ___  ___  ( __)  | .`. ;   ___  ___  
 / .-, \ (   )(   ) (   __)    /    \  (   )(   ) (''")  | |(___) (   )(   ) 
(__) ; |  | |  | |   | |      |  .-. ;  | |  | |   | |   | |_      | |  | |  
  .'`  |  | |  | |   | | ___  | |  | |   \ `' /    | |  (   __)    | |  | |  
 / .'| |  | |  | |   | |(   ) | |  | |   / ,. \    | |   | |       | '  | |  
| /  | |  | |  | |   | | | |  | |  | |  ' .  ; .   | |   | |       '  `-' |  
; |  ; |  | |  ; '   | ' | |  | '  | |  | |  | |   | |   | |        `.__. |  
' `-'  |  ' `-'  /   ' `-' ;  '  `-' /  | |  | |   | |   | |        ___ | |  
`.__.'_.   '.__.'     `.__.    `.__.'  (___)(___) (___) (___)      (   )' |  
                                                                    ; `-' '  
                                                                     .__.'   
www.autoxify.io
*/

pragma solidity >=0.4.23 <0.6.0;

contract Autoxify {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint A3MaxLevel;
        uint A6MaxLevel;
        uint A3Income;
        uint A6Income;
        
        mapping(uint8 => bool) activeA3Levels;
        mapping(uint8 => bool) activeA6Levels;
        
        mapping(uint8 => A3) A3Matrix;
        mapping(uint8 => A6) A6Matrix;
    }
    
    struct A3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct A6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    uint public totalearnedtrx = 0 trx;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user,uint indexed userId, address indexed referrer,uint referrerId, uint8 matrix, uint8 level, uint8 place);
    event MissedTronReceive(address indexed receiver,uint receiverId, address indexed from,uint indexed fromId, uint8 matrix, uint8 level);
    event SentDividends(address indexed from,uint indexed fromId, address indexed receiver,uint receiverId, uint8 matrix, uint8 level, bool isExtra);
    
    constructor(address ownerAddress) public {
        levelPrice[1] = 250 trx;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            A3MaxLevel:uint(0),
            A6MaxLevel:uint(0),
            A3Income:uint8(0),
            A6Income:uint8(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeA3Levels[i] = true;
            users[ownerAddress].activeA6Levels[i] = true;
        }
        users[ownerAddress].A3MaxLevel = 12;
        users[ownerAddress].A6MaxLevel = 12;
        userIds[1] = ownerAddress;
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(!users[msg.sender].activeA3Levels[level], "level already activated");
            require(users[msg.sender].activeA3Levels[level - 1], "previous level should be activated");

            if (users[msg.sender].A3Matrix[level-1].blocked) {
                users[msg.sender].A3Matrix[level-1].blocked = false;
            }
    
            address freeA3Referrer = findFreeA3Referrer(msg.sender, level);
            users[msg.sender].A3MaxLevel = level;
            users[msg.sender].A3Matrix[level].currentReferrer = freeA3Referrer;
            users[msg.sender].activeA3Levels[level] = true;
            updateA3Referrer(msg.sender, freeA3Referrer, level);
             totalearnedtrx = totalearnedtrx+levelPrice[level];
            emit Upgrade(msg.sender, freeA3Referrer, 1, level);

        } else {
            require(!users[msg.sender].activeA6Levels[level], "level already activated"); 
            require(users[msg.sender].activeA6Levels[level - 1], "previous level should be activated"); 

            if (users[msg.sender].A6Matrix[level-1].blocked) {
                users[msg.sender].A6Matrix[level-1].blocked = false;
            }

            address freeA6Referrer = findFreeA6Referrer(msg.sender, level);
            users[msg.sender].A6MaxLevel = level;
            users[msg.sender].activeA6Levels[level] = true;
            updateA6Referrer(msg.sender, freeA6Referrer, level);
            
        
          totalearnedtrx = totalearnedtrx+levelPrice[level];
            emit Upgrade(msg.sender, freeA6Referrer, 2, level);
        }
        
        
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 500 trx, "registration cost 500");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            A3MaxLevel:1,
            A6MaxLevel:1,
            A3Income:0 trx,
            A6Income:0 trx
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeA3Levels[1] = true; 
        users[userAddress].activeA6Levels[1] = true;
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
         totalearnedtrx = totalearnedtrx+100 trx;
        users[referrerAddress].partnersCount++;

        address freeA3Referrer = findFreeA3Referrer(userAddress, 1);
        users[userAddress].A3Matrix[1].currentReferrer = freeA3Referrer;
        updateA3Referrer(userAddress, freeA3Referrer, 1);

        updateA6Referrer(userAddress, findFreeA6Referrer(userAddress, 1), 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateA3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].A3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].A3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress, users[referrerAddress].id, 1, level, uint8(users[referrerAddress].A3Matrix[level].referrals.length));
            return sendTronDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 1, level, 3);
        //close matrix
        users[referrerAddress].A3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeA3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].A3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeA3Referrer(referrerAddress, level);
            if (users[referrerAddress].A3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].A3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].A3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateA3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendTronDividends(owner, userAddress, 1, level);
            users[owner].A3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    function updateA6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeA6Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].A6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].A6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 2, level, uint8(users[referrerAddress].A6Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].A6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendTronDividends(referrerAddress, userAddress, 2, level);
            }
            
            address ref = users[referrerAddress].A6Matrix[level].currentReferrer;            
            users[ref].A6Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].A6Matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].A6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].A6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].A6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,users[userAddress].id, ref,users[ref].id, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress,users[userAddress].id,ref,users[ref].id, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].A6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].A6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,users[userAddress].id, ref,users[ref].id, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress,users[userAddress].id, ref,users[ref].id, 2, level, 4);
                }
            } else if (len == 2 && users[ref].A6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].A6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress,users[userAddress].id, ref,users[ref].id, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress,users[userAddress].id, ref,users[ref].id, 2, level, 6);
                }
            }

            return updateA6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].A6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].A6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].A6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].A6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].A6Matrix[level].closedPart)) {

                updateA6(userAddress, referrerAddress, level, true);
                return updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].A6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].A6Matrix[level].closedPart) {
                updateA6(userAddress, referrerAddress, level, true);
                return updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateA6(userAddress, referrerAddress, level, false);
                return updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].A6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateA6(userAddress, referrerAddress, level, false);
            return updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].A6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateA6(userAddress, referrerAddress, level, true);
            return updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[0]].A6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]].A6Matrix[level].firstLevelReferrals.length) {
            updateA6(userAddress, referrerAddress, level, false);
        } else {
            updateA6(userAddress, referrerAddress, level, true);
        }
        
        updateA6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateA6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[0]].A6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress,users[userAddress].id, users[referrerAddress].A6Matrix[level].firstLevelReferrals[0],users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[0]].id, 2, level, uint8(users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[0]].A6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 2, level, 2 + uint8(users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[0]].A6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].A6Matrix[level].currentReferrer = users[referrerAddress].A6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]].A6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress,users[userAddress].id, users[referrerAddress].A6Matrix[level].firstLevelReferrals[1],users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]].id, 2, level, uint8(users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]].A6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress,users[userAddress].id, referrerAddress,users[referrerAddress].id, 2, level, 4 + uint8(users[users[referrerAddress].A6Matrix[level].firstLevelReferrals[1]].A6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].A6Matrix[level].currentReferrer = users[referrerAddress].A6Matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateA6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].A6Matrix[level].secondLevelReferrals.length < 4) {
            return sendTronDividends(referrerAddress, userAddress, 2, level);
        }
        
        address[] memory A6 = users[users[referrerAddress].A6Matrix[level].currentReferrer].A6Matrix[level].firstLevelReferrals;
        
        if (A6.length == 2) {
            if (A6[0] == referrerAddress ||
                A6[1] == referrerAddress) {
                users[users[referrerAddress].A6Matrix[level].currentReferrer].A6Matrix[level].closedPart = referrerAddress;
            } else if (A6.length == 1) {
                if (A6[0] == referrerAddress) {
                    users[users[referrerAddress].A6Matrix[level].currentReferrer].A6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].A6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].A6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].A6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeA6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].A6Matrix[level].blocked = true;
        }

        users[referrerAddress].A6Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeA6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateA6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendTronDividends(owner, userAddress, 2, level);
        }
    }
    
    function findFreeA3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeA3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeA6Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeA6Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
        
    function usersActiveA3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeA3Levels[level];
    }

    function usersActiveA6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeA6Levels[level];
    }

    function get3XMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, uint, bool) {
        return (users[userAddress].A3Matrix[level].currentReferrer,
                users[userAddress].A3Matrix[level].referrals,
                users[userAddress].A3Matrix[level].reinvestCount,
                users[userAddress].A3Matrix[level].blocked);
    }

    function getA6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, uint, address) {
        return (users[userAddress].A6Matrix[level].currentReferrer,
                users[userAddress].A6Matrix[level].firstLevelReferrals,
                users[userAddress].A6Matrix[level].secondLevelReferrals,
                users[userAddress].A6Matrix[level].blocked,
                users[userAddress].A6Matrix[level].reinvestCount,
                users[userAddress].A6Matrix[level].closedPart);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findTronReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].A3Matrix[level].blocked) {
                    emit MissedTronReceive(receiver,users[receiver].id, _from,users[_from].id, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].A3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].A6Matrix[level].blocked) {
                    emit MissedTronReceive(receiver,users[receiver].id, _from,users[_from].id, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].A6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendTronDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findTronReceiver(userAddress, _from, matrix, level);

if(matrix==1)
{
 
        
           
        users[userAddress].A3Income +=levelPrice[level] ;
}
else if(matrix==2)
{
 
        users[userAddress].A6Income +=levelPrice[level] ;    
}

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
       
        emit SentDividends(_from,users[_from].id, receiver,users[receiver].id, matrix, level, isExtraDividends);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}