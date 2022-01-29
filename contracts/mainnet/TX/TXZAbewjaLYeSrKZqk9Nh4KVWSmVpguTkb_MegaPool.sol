//SourceUnit: megapool.sol

pragma solidity 0.5.9;

contract MegaPool {
    address public ownerWallet;
    uint public currUserID = 0;
    uint public pool1currUserID = 0;
    uint public pool2currUserID = 0;
    uint public pool3currUserID = 0;
    uint public pool4currUserID = 0;
    uint public pool5currUserID = 0;
    uint public pool6currUserID = 0;
    uint public pool7currUserID = 0;
    uint public pool8currUserID = 0;
    
    uint public pool1activeUserID = 0;
    uint public pool2activeUserID = 0;
    uint public pool3activeUserID = 0;
    uint public pool4activeUserID = 0;
    uint public pool5activeUserID = 0;
    uint public pool6activeUserID = 0;
    uint public pool7activeUserID = 0;
    uint public pool8activeUserID = 0;
    
    
    uint public unlimited_level_price=0;
   
    struct UserStruct {
      bool isExist;
      uint id;
      uint referrerID;
      uint referredUsers;
      mapping(uint => uint) levelExpired;
    }
    
    struct PoolUserStruct {
      bool isExist;
      uint id;
      uint payment_received; 
    }
    
    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
     
    mapping (address => PoolUserStruct) public pool1users;
    mapping (uint => address) public pool1userList;
     
    mapping (address => PoolUserStruct) public pool2users;
    mapping (uint => address) public pool2userList;
     
    mapping (address => PoolUserStruct) public pool3users;
    mapping (uint => address) public pool3userList;
     
    mapping (address => PoolUserStruct) public pool4users;
    mapping (uint => address) public pool4userList;
     
    mapping (address => PoolUserStruct) public pool5users;
    mapping (uint => address) public pool5userList;
     
    mapping (address => PoolUserStruct) public pool6users;
    mapping (uint => address) public pool6userList;
     
    mapping (address => PoolUserStruct) public pool7users;
    mapping (uint => address) public pool7userList;
     
    mapping (address => PoolUserStruct) public pool8users;
    mapping (uint => address) public pool8userList;
     
    uint LEVEL_PRICE = 500  *(10**6);

    uint REGESTRATION_FESS=500  * (10**6);
    uint pool1_price=500  * (10**6);
    uint pool2_price=1000 * (10**6) ;
    uint pool3_price=2000 * (10**6);
    uint pool4_price=4000 * (10**6);
    uint pool5_price=8000 * (10**6);
    uint pool6_price=16000 * (10**6);
    uint pool7_price=32000 * (10**6);
    uint pool8_price=64000 * (10**6);

    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
        
    event regPoolEntry(address indexed _user,uint _value, uint _time);
     
       
    event getPoolPayment(address indexed _user,address indexed _receiver, uint _value, uint _time);
     
      constructor() public {
        ownerWallet = msg.sender;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referredUsers:0
           
        });
        
        users[ownerWallet] = userStruct;
       userList[currUserID] = ownerWallet;
       
       
         PoolUserStruct memory pooluserStruct;
        
        pool1currUserID++;

        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
    pool1activeUserID=pool1currUserID;
       pool1users[msg.sender] = pooluserStruct;
       pool1userList[pool1currUserID]=msg.sender;
      
        
        pool2currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
    pool2activeUserID=pool2currUserID;
       pool2users[msg.sender] = pooluserStruct;
       pool2userList[pool2currUserID]=msg.sender;
       
       
        pool3currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
    pool3activeUserID=pool3currUserID;
       pool3users[msg.sender] = pooluserStruct;
       pool3userList[pool3currUserID]=msg.sender;
       
       
         pool4currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
    pool4activeUserID=pool4currUserID;
       pool4users[msg.sender] = pooluserStruct;
       pool4userList[pool4currUserID]=msg.sender;

        
          pool5currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
    pool5activeUserID=pool5currUserID;
       pool5users[msg.sender] = pooluserStruct;
       pool5userList[pool5currUserID]=msg.sender;
       
       
         pool6currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
    pool6activeUserID=pool6currUserID;
       pool6users[msg.sender] = pooluserStruct;
       pool6userList[pool6currUserID]=msg.sender;
       
         pool7currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool7currUserID,
            payment_received:0
        });
    pool7activeUserID=pool7currUserID;
       pool7users[msg.sender] = pooluserStruct;
       pool7userList[pool7currUserID]=msg.sender;
       
       pool8currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool8currUserID,
            payment_received:0
        });
    pool8activeUserID=pool8currUserID;
       pool8users[msg.sender] = pooluserStruct;
       pool8userList[pool8currUserID]=msg.sender;
       
       
      }
     
      function regUser(uint _referrerID) public payable {
        require(!users[msg.sender].isExist, "User Exists");
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referral ID');
        require(msg.value == REGESTRATION_FESS, 'Incorrect Value');

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referredUsers:0
        });


        users[msg.sender] = userStruct;
        userList[currUserID]=msg.sender;

        users[userList[users[msg.sender].referrerID]].referredUsers++;

        payReferral(1,msg.sender);
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
      }
   
   
      function payReferral(uint _level, address _user) internal {
        address referer;

        referer = userList[users[_user].referrerID];
        uint level_price_local=0;
        level_price_local=LEVEL_PRICE;

        address(uint160(referer)).transfer(level_price_local);
        emit getMoneyForLevelEvent(referer, _user, _level, now);
      }
   
      function buyPool1() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(!pool1users[msg.sender].isExist, "Already in AutoPool");

        require(msg.value == pool1_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool1Currentuser=pool1userList[pool1activeUserID];

        pool1currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });

        pool1users[msg.sender] = userStruct;
        pool1userList[pool1currUserID]=msg.sender;
        address(uint160(pool1Currentuser)).transfer(pool1_price);

        pool1users[pool1Currentuser].payment_received+=1;
        if(pool1users[pool1Currentuser].payment_received>=2)
        {
            pool1activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool1Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }
    
    
      function buyPool2() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool1users[msg.sender].isExist, "You do not have previous pool");
        require(!pool2users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool2_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool2Currentuser=pool2userList[pool2activeUserID];

        pool2currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });

        pool2users[msg.sender] = userStruct;
        pool2userList[pool2currUserID]=msg.sender;
        address(uint160(pool2Currentuser)).transfer(pool2_price);

        pool2users[pool2Currentuser].payment_received+=1;
        if(pool2users[pool2Currentuser].payment_received>=3)
        {
            pool2activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool2Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool3() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool2users[msg.sender].isExist, "You do not have previous pool");
        require(!pool3users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool3_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool3Currentuser=pool3userList[pool3activeUserID];

        pool3currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });

        pool3users[msg.sender] = userStruct;
        pool3userList[pool3currUserID]=msg.sender;
        address(uint160(pool3Currentuser)).transfer(pool3_price);

        pool3users[pool3Currentuser].payment_received+=1;
        if(pool3users[pool3Currentuser].payment_received>=3)
        {
            pool3activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool3Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool4() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool3users[msg.sender].isExist, "You do not have previous pool");
        require(!pool4users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool4_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool4Currentuser=pool4userList[pool4activeUserID];

        pool4currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });

        pool4users[msg.sender] = userStruct;
        pool4userList[pool4currUserID]=msg.sender;
        address(uint160(pool4Currentuser)).transfer(pool4_price);

        pool4users[pool4Currentuser].payment_received+=1;
        if(pool4users[pool4Currentuser].payment_received>=3)
        {
            pool4activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool4Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool5() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool4users[msg.sender].isExist, "You do not have previous pool");
        require(!pool5users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool5_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool5Currentuser=pool5userList[pool5activeUserID];

        pool5currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });

        pool5users[msg.sender] = userStruct;
        pool5userList[pool5currUserID]=msg.sender;
        address(uint160(pool5Currentuser)).transfer(pool5_price);

        pool5users[pool5Currentuser].payment_received+=1;
        if(pool5users[pool5Currentuser].payment_received>=3)
        {
            pool5activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool5Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool6() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool5users[msg.sender].isExist, "You do not have previous pool");
        require(!pool6users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool6_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool6Currentuser=pool6userList[pool6activeUserID];

        pool6currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });

        pool6users[msg.sender] = userStruct;
        pool6userList[pool6currUserID]=msg.sender;
        address(uint160(pool6Currentuser)).transfer(pool6_price);

        pool6users[pool6Currentuser].payment_received+=1;
        if(pool6users[pool6Currentuser].payment_received>=3)
        {
            pool6activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool6Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool7() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool6users[msg.sender].isExist, "You do not have previous pool");
        require(!pool7users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool7_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool7Currentuser=pool7userList[pool7activeUserID];

        pool7currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool7currUserID,
            payment_received:0
        });

        pool7users[msg.sender] = userStruct;
        pool7userList[pool7currUserID]=msg.sender;
        address(uint160(pool7Currentuser)).transfer(pool7_price);

        pool7users[pool7Currentuser].payment_received+=1;
        if(pool7users[pool7Currentuser].payment_received>=3)
        {
            pool7activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool7Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }

      function buyPool8() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool7users[msg.sender].isExist, "You do not have previous pool");
        require(!pool8users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool8_price, 'Incorrect Value');

        PoolUserStruct memory userStruct;
        address pool8Currentuser=pool8userList[pool8activeUserID];

        pool8currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool8currUserID,
            payment_received:0
        });

        pool8users[msg.sender] = userStruct;
        pool8userList[pool8currUserID]=msg.sender;
        address(uint160(pool8Currentuser)).transfer(pool8_price);

        pool8users[pool8Currentuser].payment_received+=1;
        if(pool8users[pool8Currentuser].payment_received>=3)
        {
            pool8activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool8Currentuser, msg.value, now);

        emit regPoolEntry(msg.sender, msg.value, now);
      }
}