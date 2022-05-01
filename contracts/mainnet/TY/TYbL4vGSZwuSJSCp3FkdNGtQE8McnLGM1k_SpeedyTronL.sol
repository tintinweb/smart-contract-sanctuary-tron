//SourceUnit: speedytron.sol

pragma solidity 0.5.9;

contract SpeedyTronL {
    address payable public ownerWallet;
    address payable internal creator1;
    uint public currUserID = 0;
    uint public pool1currUserID = 0;
    uint public pool2currUserID = 0;
    uint public pool3currUserID = 0;
    uint public pool4currUserID = 0;
    uint public pool5currUserID = 0;
    uint public pool6currUserID = 0;
        
    uint public pool1activeUserID = 0;
    uint public pool2activeUserID = 0;
    uint public pool3activeUserID = 0;
    uint public pool4activeUserID = 0;
    uint public pool5activeUserID = 0;
    uint public pool6activeUserID = 0;
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
             
    uint LEVEL_PRICE = 50  *(10**6);
    uint REGESTRATION_FESS=50  * (10**6);
    uint pool1_price=50  * (10**6);
    uint pool2_price=100 * (10**6) ;
    uint pool3_price=200 * (10**6);
    uint pool4_price=300 * (10**6);
    uint pool5_price=400 * (10**6);
    uint pool6_price=500 * (10**6);
   
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);
        
    event regPoolEntry(address indexed _user,uint _value, uint _time);
            
    event getPoolPayment(address indexed _user,address indexed _receiver, uint _value, uint _time);
     
      constructor(address payable _creator1) public {
        ownerWallet = msg.sender;
        creator1=_creator1;
    
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
                      
//// for creator1
  UserStruct memory userStruct1;
        currUserID++;

        userStruct1 = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 1,
            referredUsers:0
           });
        
       users[creator1] = userStruct1;
       userList[currUserID] =creator1;
       PoolUserStruct memory pooluserStruct1;
       pool1currUserID++;

        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
       pool1users[creator1] = pooluserStruct1;
       pool1userList[pool1currUserID]=creator1;
       
        pool2currUserID++;
        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
       pool2users[creator1] = pooluserStruct1;
       pool2userList[pool2currUserID]=creator1;
       
        pool3currUserID++;
        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
       pool3users[creator1] = pooluserStruct1;
       pool3userList[pool3currUserID]=creator1;

        pool4currUserID++;
        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
       pool4users[creator1] = pooluserStruct1;
       pool4userList[pool4currUserID]=creator1;

          pool5currUserID++;
        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
       pool5users[creator1] = pooluserStruct1;
       pool5userList[pool5currUserID]=creator1;

         pool6currUserID++;
        pooluserStruct1 = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
       pool6users[creator1] = pooluserStruct1;
       pool6userList[pool6currUserID]=creator1;    
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
        if(pool1users[pool1Currentuser].payment_received>=3)
        {
            pool1activeUserID+=1;
        }
        emit getPoolPayment(msg.sender,pool1Currentuser, msg.value, now);
        emit regPoolEntry(msg.sender, msg.value, now);
      }
        
      function buyPool2() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
        require(pool1users[msg.sender].isExist, "You do not have previous pool");
        require(!pool2users[msg.sender].isExist, "Already in GlobalSlot");
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
        require(!pool3users[msg.sender].isExist, "Already in GlobalSlot");
        require(pool2users[msg.sender].isExist, "You do not have previous pool");
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
        require(!pool4users[msg.sender].isExist, "Already in GlobalSlot");
        require(pool3users[msg.sender].isExist, "You do not have previous pool");
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
        require(!pool5users[msg.sender].isExist, "Already in GlobalSlot");
        require(pool4users[msg.sender].isExist, "You do not have previous pool");
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
        require(!pool6users[msg.sender].isExist, "Already in GlobalSlot");
        require(pool5users[msg.sender].isExist, "You do not have previous pool");
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
     }